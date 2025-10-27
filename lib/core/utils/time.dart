import 'package:intl/intl.dart';

String formatCountdown(Duration duration) {
  return formatNotificationDuration(duration);
}

String formatNotificationDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final totalSeconds = safe.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  final minutesString = minutes.toString().padLeft(2, '0');
  final secondsString = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    final hoursString = hours.toString().padLeft(2, '0');
    return '$hoursString:$minutesString:$secondsString';
  }

  return '$minutesString:$secondsString';
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yMMMd HH:mm');
  return formatter.format(dateTime.toLocal());
}
