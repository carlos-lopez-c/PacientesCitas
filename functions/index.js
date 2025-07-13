const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Función para detectar cambios en las citas y enviar notificaciones
exports.appointmentChanged = functions.firestore
    .document('appointments/{appointmentId}')
    .onWrite(async (change, context) => {
        const { appointmentId } = context.params;
        
        // Si es una eliminación
        if (!change.after.exists) {
            const beforeData = change.before.data();
            await sendNotificationToPatient(
                beforeData.patientID,
                'Cita Cancelada',
                `Su cita del ${beforeData.date} a las ${beforeData.appointmentTime} ha sido cancelada`,
                {
                    type: 'appointment_cancelled',
                    appointmentId: appointmentId,
                    date: beforeData.date,
                    time: beforeData.appointmentTime
                }
            );
            return;
        }

        const afterData = change.after.data();
        
        // Si es una nueva cita
        if (!change.before.exists) {
            await sendNotificationToPatient(
                afterData.patientID,
                'Nueva Cita Médica',
                `Se ha programado una nueva cita para el ${afterData.date} a las ${afterData.appointmentTime}`,
                {
                    type: 'new_appointment',
                    appointmentId: appointmentId,
                    date: afterData.date,
                    time: afterData.appointmentTime,
                    specialty: afterData.specialtyTherapy || '',
                    doctor: afterData.doctor || ''
                }
            );
            return;
        }

        // Si es una actualización
        const beforeData = change.before.data();
        
        // Verificar cambios en el estado
        if (beforeData.status !== afterData.status) {
            const statusMessage = getStatusMessage(afterData.status);
            await sendNotificationToPatient(
                afterData.patientID,
                'Estado de Cita Actualizado',
                `Su cita del ${afterData.date} ${statusMessage}`,
                {
                    type: 'status_changed',
                    appointmentId: appointmentId,
                    newStatus: afterData.status,
                    previousStatus: beforeData.status,
                    date: afterData.date,
                    time: afterData.appointmentTime
                }
            );
        }

        // Verificar cambios en fecha u hora
        if (beforeData.date !== afterData.date || 
            beforeData.appointmentTime !== afterData.appointmentTime) {
            await sendNotificationToPatient(
                afterData.patientID,
                'Cita Reprogramada',
                `Su cita ha sido reprogramada para el ${afterData.date} a las ${afterData.appointmentTime}`,
                {
                    type: 'appointment_updated',
                    appointmentId: appointmentId,
                    newDate: afterData.date,
                    newTime: afterData.appointmentTime,
                    previousDate: beforeData.date,
                    previousTime: beforeData.appointmentTime
                }
            );
        }

        // Verificar cambios en doctor
        if (beforeData.doctor !== afterData.doctor && afterData.doctor) {
            await sendNotificationToPatient(
                afterData.patientID,
                'Doctor Asignado',
                `Se ha asignado al Dr. ${afterData.doctor} para su cita del ${afterData.date}`,
                {
                    type: 'doctor_assigned',
                    appointmentId: appointmentId,
                    newDoctor: afterData.doctor,
                    previousDoctor: beforeData.doctor || 'No asignado',
                    date: afterData.date,
                    time: afterData.appointmentTime
                }
            );
        }
    });

// Función programada para recordatorios de citas (ejecutar diariamente)
exports.appointmentReminders = functions.pubsub
    .schedule('0 9 * * *') // Ejecutar todos los días a las 9:00 AM
    .timeZone('America/Guayaquil')
    .onRun(async (context) => {
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const tomorrowString = tomorrow.toISOString().split('T')[0];

        const appointmentsSnapshot = await admin.firestore()
            .collection('appointments')
            .where('date', '==', tomorrowString)
            .where('status', '==', 'confirmada')
            .get();

        const notificationPromises = appointmentsSnapshot.docs.map(async (doc) => {
            const appointment = doc.data();
            return sendNotificationToPatient(
                appointment.patientID,
                'Recordatorio de Cita',
                `Tienes una cita mañana a las ${appointment.appointmentTime} con ${appointment.doctor || 'el especialista'}`,
                {
                    type: 'appointment_reminder',
                    appointmentId: doc.id,
                    date: appointment.date,
                    time: appointment.appointmentTime,
                    specialty: appointment.specialtyTherapy || '',
                    doctor: appointment.doctor || ''
                }
            );
        });

        await Promise.all(notificationPromises);
        console.log(`Enviados ${notificationPromises.length} recordatorios de citas`);
    });

// Función auxiliar para enviar notificaciones a un paciente específico
async function sendNotificationToPatient(patientId, title, body, data) {
    try {
        // Obtener el token del dispositivo del paciente
        const tokenDoc = await admin.firestore()
            .collection('user_tokens')
            .doc(patientId)
            .get();

        if (!tokenDoc.exists) {
            console.log(`No se encontró token para el paciente: ${patientId}`);
            return;
        }

        const { token } = tokenDoc.data();

        if (!token) {
            console.log(`Token vacío para el paciente: ${patientId}`);
            return;
        }

        const message = {
            notification: {
                title: title,
                body: body,
            },
            data: {
                ...data,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
                notification: {
                    channelId: 'citas_channel',
                    priority: 'high',
                    defaultSound: true,
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
            token: token,
        };

        const response = await admin.messaging().send(message);
        console.log('Notificación enviada exitosamente:', response);

    } catch (error) {
        console.error('Error enviando notificación:', error);
        
        // Si el token es inválido, eliminarlo de la base de datos
        if (error.code === 'messaging/invalid-registration-token' || 
            error.code === 'messaging/registration-token-not-registered') {
            await admin.firestore()
                .collection('user_tokens')
                .doc(patientId)
                .delete();
            console.log(`Token inválido eliminado para el paciente: ${patientId}`);
        }
    }
}

// Función auxiliar para obtener el mensaje de estado
function getStatusMessage(status) {
    switch (status.toLowerCase()) {
        case 'confirmada':
            return 'ha sido confirmada';
        case 'pendiente':
            return 'está pendiente de confirmación';
        case 'cancelada':
            return 'ha sido cancelada';
        case 'completada':
            return 'ha sido completada';
        case 'en_proceso':
            return 'está en proceso';
        default:
            return `cambió de estado a: ${status}`;
    }
}

// Función para manejar la actualización de tokens cuando el usuario se autentica
exports.updateUserToken = functions.firestore
    .document('user_tokens/{userId}')
    .onCreate(async (snap, context) => {
        const { userId } = context.params;
        const { token } = snap.data();
        
        console.log(`Nuevo token registrado para usuario ${userId}: ${token}`);
        
        // Suscribir al tópico general de la aplicación
        try {
            await admin.messaging().subscribeToTopic([token], 'general_updates');
            console.log(`Usuario ${userId} suscrito al tópico general_updates`);
        } catch (error) {
            console.error('Error suscribiendo al tópico:', error);
        }
    });

// Función para enviar notificaciones masivas (opcional)
exports.sendBulkNotification = functions.https.onCall(async (data, context) => {
    // Verificar que el usuario tenga permisos de administrador
    if (!context.auth || !context.auth.token.admin) {
        throw new functions.https.HttpsError(
            'permission-denied',
            'Solo los administradores pueden enviar notificaciones masivas.'
        );
    }

    const { title, body, topic = 'general_updates' } = data;

    const message = {
        notification: {
            title: title,
            body: body,
        },
        topic: topic,
    };

    try {
        const response = await admin.messaging().send(message);
        return { success: true, messageId: response };
    } catch (error) {
        console.error('Error enviando notificación masiva:', error);
        throw new functions.https.HttpsError('internal', 'Error enviando notificación');
    }
});