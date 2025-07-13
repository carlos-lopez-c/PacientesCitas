class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String type;
  final bool read;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    required this.type,
    this.read = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? type,
    bool? read,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'read': read,
    };
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? '',
      read: json['read'] ?? false,
    );
  }

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, body: $body, type: $type, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.read == read;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        read.hashCode;
  }
}

enum NotificationType {
  newAppointment('new_appointment'),
  appointmentUpdated('appointment_updated'),
  appointmentCancelled('appointment_cancelled'),
  appointmentReminder('appointment_reminder'),
  statusChanged('status_changed');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.newAppointment,
    );
  }
}