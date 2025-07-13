import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fundacion_paciente_app/notifications/domain/datasources/notification_datasource.dart';
import 'package:fundacion_paciente_app/notifications/domain/entities/notification_entity.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class FcmDatasourceImpl implements NotificationDatasource {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final StreamController<NotificationEntity> _messageController = StreamController<NotificationEntity>.broadcast();
  final StreamController<NotificationEntity> _messageOpenedController = StreamController<NotificationEntity>.broadcast();

  @override
  Future<void> initializeNotifications() async {
    print('🔧 Initializing FCM and local notifications...');
    
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    final initialized = await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Notification tapped: ${response.payload}');
        if (response.payload != null) {
          final data = json.decode(response.payload!) as Map<String, dynamic>;
          final notification = NotificationEntity(
            id: data['id'] ?? '',
            title: data['title'] ?? '',
            body: data['body'] ?? '',
            data: data,
            timestamp: DateTime.now(),
            type: data['type'] ?? '',
          );
          _messageOpenedController.add(notification);
        }
      },
    );
    
    print('📱 Local notifications initialized: $initialized');

    // Crear canal de notificaciones para Android
    await _createNotificationChannel();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 FCM message received in foreground');
      final notification = _mapRemoteMessageToEntity(message);
      _messageController.add(notification);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 FCM message opened app');
      final notification = _mapRemoteMessageToEntity(message);
      _messageOpenedController.add(notification);
    });
    
    print('✅ FCM initialization completed');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'citas_channel',
      'Notificaciones de Citas',
      description: 'Notificaciones relacionadas con citas médicas',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    print('📱 Notification channel created: ${channel.id}');
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  @override
  Future<void> requestPermissions() async {
    print('🔐 Requesting notification permissions...');
    
    try {
      // Solicitar permisos usando permission_handler para Android 13+
      final PermissionStatus status = await Permission.notification.request();
      print('📱 Permission status: $status');
      
      if (status == PermissionStatus.denied) {
        print('⚠️ Notification permission denied');
        return;
      }
      
      if (status == PermissionStatus.permanentlyDenied) {
        print('❌ Notification permission permanently denied');
        return;
      }
      
      // Solicitar permisos FCM (especialmente para iOS)
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('🔐 FCM permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('🟡 User granted provisional notification permissions');
      } else {
        print('❌ User declined or has not accepted notification permissions');
      }
      
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  Future<bool> checkNotificationPermission() async {
    try {
      final PermissionStatus status = await Permission.notification.status;
      print('🔍 Current notification permission status: $status');
      return status == PermissionStatus.granted;
    } catch (e) {
      print('❌ Error checking permission: $e');
      return false;
    }
  }

  @override
  Stream<NotificationEntity> get onMessage => _messageController.stream;

  @override
  Stream<NotificationEntity> get onMessageOpenedApp => _messageOpenedController.stream;

  @override
  Future<NotificationEntity?> getInitialMessage() async {
    final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      return _mapRemoteMessageToEntity(message);
    }
    return null;
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    print('📱 FCM: showLocalNotification called');
    print('📱 Title: $title');
    print('📱 Body: $body');
    print('📱 Data: $data');

    // Verificar permisos antes de mostrar la notificación
    final hasPermission = await checkNotificationPermission();
    if (!hasPermission) {
      print('❌ No notification permission, cannot show notification');
      print('💡 Requesting permission...');
      await requestPermissions();
      
      // Verificar nuevamente después de solicitar
      final hasPermissionAfterRequest = await checkNotificationPermission();
      if (!hasPermissionAfterRequest) {
        print('❌ Still no permission after request, aborting notification');
        return;
      }
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'citas_channel',
        'Notificaciones de Citas',
        channelDescription: 'Notificaciones relacionadas con citas médicas',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      print('📱 Showing notification with ID: $notificationId');

      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: data != null ? json.encode(data) : null,
      );
      
      print('✅ Local notification displayed successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  @override
  Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('user_tokens').doc(userId).set({
        'token': token,
        'platform': 'android',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving token to Firestore: $e');
    }
  }

  @override
  void handleBackgroundMessage() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  NotificationEntity _mapRemoteMessageToEntity(RemoteMessage message) {
    return NotificationEntity(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
      timestamp: DateTime.now(),
      type: message.data['type'] ?? 'general',
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    await showLocalNotification(
      title: message.notification?.title ?? 'Nueva notificación',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }
}