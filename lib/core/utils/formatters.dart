import 'package:intl/intl.dart';

/// Formats a whole-kyat amount with thousands separators: `3,200 MMK`.
String formatMmk(int amount) => '${formatThousands(amount)} MMK';

/// `680000` -> `680,000`.
String formatThousands(num value) => NumberFormat.decimalPattern('en').format(value);

/// `297` seconds -> `4:57`.
String formatCountdown(Duration remaining) {
  final minutes = remaining.inMinutes;
  final seconds = remaining.inSeconds.remainder(Duration.secondsPerMinute);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
