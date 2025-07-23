import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paciente_citas_1/notifications/domain/entities/notification_entity.dart';
import 'package:paciente_citas_1/notifications/domain/repositories/notification_repository.dart';
import 'package:paciente_citas_1/notifications/infrastructure/datasources/fcm_datasource_impl.dart';
import 'package:paciente_citas_1/notifications/infrastructure/repositories/notification_repository_impl.dart';


final notificationDatasourceProvider = Provider<FcmDatasourceImpl>((ref) {
  return FcmDatasourceImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final datasource = ref.watch(notificationDatasourceProvider);
  return NotificationRepositoryImpl(datasource);
});

class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isInitialized;
  final String? deviceToken;
  final bool permissionsGranted;
  final bool permissionsRequested;
  final String? permissionError;

  const NotificationState({
    this.notifications = const [],
    this.isInitialized = false,
    this.deviceToken,
    this.permissionsGranted = false,
    this.permissionsRequested = false,
    this.permissionError,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isInitialized,
    String? deviceToken,
    bool? permissionsGranted,
    bool? permissionsRequested,
    String? permissionError,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isInitialized: isInitialized ?? this.isInitialized,
      deviceToken: deviceToken ?? this.deviceToken,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      permissionsRequested: permissionsRequested ?? this.permissionsRequested,
      permissionError: permissionError ?? this.permissionError,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    print('🔧 NotificationNotifier: Initializing...');
    
    try {
      await _repository.initializeNotifications();
      
      print('🔐 NotificationNotifier: Requesting permissions...');
      await _repository.requestPermissions();
      
      final hasPermission = await _repository.checkNotificationPermission();
      final token = await _repository.getDeviceToken();
      
      print('✅ NotificationNotifier: Permission granted: $hasPermission');
      print('📱 NotificationNotifier: Device token: ${token?.substring(0, 20)}...');
      
      state = state.copyWith(
        isInitialized: true,
        deviceToken: token,
        permissionsGranted: hasPermission,
        permissionsRequested: true,
        permissionError: hasPermission ? null : 'Permisos de notificación no otorgados',
      );

      _listenToMessages();
      _listenToMessageOpenedApp();
      _checkInitialMessage();
      
    } catch (e) {
      print('❌ NotificationNotifier: Error during initialization: $e');
      state = state.copyWith(
        isInitialized: true,
        permissionsGranted: false,
        permissionsRequested: true,
        permissionError: 'Error al inicializar notificaciones: $e',
      );
    }
  }

  void _listenToMessages() {
    _repository.onMessage.listen((notification) {
      addNotification(notification);
    });
  }

  void _listenToMessageOpenedApp() {
    _repository.onMessageOpenedApp.listen((notification) {
      addNotification(notification);
      handleNotificationTap(notification);
    });
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await _repository.getInitialMessage();
    if (initialMessage != null) {
      addNotification(initialMessage);
      handleNotificationTap(initialMessage);
    }
  }

  void addNotification(NotificationEntity notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }

  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(read: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void clearNotifications() {
    state = state.copyWith(notifications: []);
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _repository.showLocalNotification(
      title: title,
      body: body,
      data: data,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _repository.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _repository.unsubscribeFromTopic(topic);
  }

  Future<void> saveTokenToFirestore(String userId) async {
    if (state.deviceToken != null) {
      await _repository.saveTokenToFirestore(userId, state.deviceToken!);
    }
  }

  // Función para probar notificaciones locales
  Future<void> testLocalNotification() async {
    print('🧪 Testing local notification...');
    print('🔍 Current permission status: ${state.permissionsGranted}');
    
    if (!state.permissionsGranted) {
      print('⚠️ No permissions, requesting...');
      await requestPermissions();
    }
    
    await _repository.showLocalNotification(
      title: 'Prueba de Notificación',
      body: 'Esta es una notificación de prueba para verificar que funciona correctamente',
      data: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> requestPermissions() async {
    print('🔐 Requesting permissions manually...');
    await _repository.requestPermissions();
    
    final hasPermission = await _repository.checkNotificationPermission();
    state = state.copyWith(
      permissionsGranted: hasPermission,
      permissionsRequested: true,
      permissionError: hasPermission ? null : 'Permisos de notificación no otorgados',
    );
    
    print('✅ Permission request result: $hasPermission');
  }

  Future<bool> checkPermissions() async {
    final hasPermission = await _repository.checkNotificationPermission();
    state = state.copyWith(permissionsGranted: hasPermission);
    return hasPermission;
  }

  void handleNotificationTap(NotificationEntity notification) {
    markAsRead(notification.id);
    
    final type = NotificationType.fromString(notification.type);
    switch (type) {
      case NotificationType.newAppointment:
      case NotificationType.appointmentUpdated:
      case NotificationType.appointmentReminder:
        break;
      case NotificationType.appointmentCancelled:
        break;
      case NotificationType.statusChanged:
        break;
    }
  }

  List<NotificationEntity> get unreadNotifications {
    return state.notifications.where((n) => !n.read).toList();
  }

  int get unreadCount => unreadNotifications.length;
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.notifications.where((n) => !n.read).length;
});

final notificationStreamProvider = StreamProvider<NotificationEntity>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.onMessage;
});