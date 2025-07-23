import 'package:paciente_citas_1/notifications/domain/datasources/notification_datasource.dart';
import 'package:paciente_citas_1/notifications/domain/entities/notification_entity.dart';
import 'package:paciente_citas_1/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource _datasource;

  NotificationRepositoryImpl(this._datasource);

  @override
  Future<void> initializeNotifications() {
    return _datasource.initializeNotifications();
  }

  @override
  Future<String?> getDeviceToken() {
    return _datasource.getDeviceToken();
  }

  @override
  Future<void> requestPermissions() {
    return _datasource.requestPermissions();
  }

  @override
  Future<bool> checkNotificationPermission() {
    return _datasource.checkNotificationPermission();
  }

  @override
  Stream<NotificationEntity> get onMessage => _datasource.onMessage;

  @override
  Stream<NotificationEntity> get onMessageOpenedApp => _datasource.onMessageOpenedApp;

  @override
  Future<NotificationEntity?> getInitialMessage() {
    return _datasource.getInitialMessage();
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return _datasource.showLocalNotification(
      title: title,
      body: body,
      data: data,
    );
  }

  @override
  Future<void> subscribeToTopic(String topic) {
    return _datasource.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    return _datasource.unsubscribeFromTopic(topic);
  }

  @override
  Future<void> saveTokenToFirestore(String userId, String token) {
    return _datasource.saveTokenToFirestore(userId, token);
  }

  @override
  void handleBackgroundMessage() {
    _datasource.handleBackgroundMessage();
  }
}