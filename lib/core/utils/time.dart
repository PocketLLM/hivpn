import 'package:intl/intl.dart';

String formatCountdown(Duration duration) {
  return formatNotificationDuration(duration);
}

String formatNotificationDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final totalSeconds = safe.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final minutesString = minutes.toString().padLeft(2, '0');
  final secondsString = seconds.toString().padLeft(2, '0');
  return '$minutesString:$secondsString';
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yMMMd HH:mm');
  return formatter.format(dateTime.toLocal());
}
