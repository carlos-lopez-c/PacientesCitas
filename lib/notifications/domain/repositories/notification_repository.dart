import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> initializeNotifications();
  
  Future<String?> getDeviceToken();
  
  Future<void> requestPermissions();
  
  Future<bool> checkNotificationPermission();
  
  Stream<NotificationEntity> get onMessage;
  
  Stream<NotificationEntity> get onMessageOpenedApp;
  
  Future<NotificationEntity?> getInitialMessage();
  
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
  
  Future<void> subscribeToTopic(String topic);
  
  Future<void> unsubscribeFromTopic(String topic);
  
  Future<void> saveTokenToFirestore(String userId, String token);
  
  void handleBackgroundMessage();
}