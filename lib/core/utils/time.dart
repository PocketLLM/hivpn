import 'package:intl/intl.dart';

String formatCountdown(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = (totalSeconds ~/ 60).clamp(0, 99 * 60);
  final seconds = totalSeconds % 60;
  final minutesString = (minutes).toString().padLeft(2, '0');
  final secondsString = seconds.toString().padLeft(2, '0');
  return '$minutesString:$secondsString';
}

String formatDateTime(DateTime dateTime) {
  final formatter = DateFormat('yMMMd HH:mm');
  return formatter.format(dateTime.toLocal());
}
