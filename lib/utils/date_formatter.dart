import 'package:intl/intl.dart';

class DateFormatter {
  static String formatChatTime(DateTime messageTime) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final messageDate = DateTime(
      messageTime.year,
      messageTime.month,
      messageTime.day,
    );

    // Today → show time (AM/PM)
    if (messageDate == today) {
      return DateFormat('hh:mm a').format(messageTime);
    }
    // Yesterday
    else if (messageDate == yesterday) {
      return "Yesterday";
    }
    // Older → show date
    else {
      return DateFormat('dd MMM yyyy').format(messageTime);
    }
  }
}
