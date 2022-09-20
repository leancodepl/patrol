import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Represents a notification visible in the notification shade.
@freezed
class Notification with _$Notification {
  /// Creates a new [Notification].
  const factory Notification({
    required String? appName,
    required String title,
    required String content,
  }) = _Notification;

  /// Creates a new [Notification] from JSON.
  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}
