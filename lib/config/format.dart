import 'constants.dart';
import 'package:intl/intl.dart';

String formatDateToShortMonth(DateTime date){
  return "${kShortMonths[date.month - 1].substring(0, 3)}";
}

String formatDateToWeekdayAndDate(DateTime date){
  return "${kWeekdaysFull[DateFormat('EEEE').format(date)]}, ${date.day} ${kMonths[date.month-1]} ${date.year}";
}
String formatDateToWeekdayAndShortDate(DateTime date){
  return "${kWeekdays[DateFormat('EEEE').format(date)]}, ${date.day} ${kMonths[date.month-1].substring(0,3)} ${date.year}";
}
String formatDateToWeekdayDateAndHour(DateTime date){
  return "${kWeekdays[DateFormat('EEEE').format(date)]}, ${date.day} ${kMonths[date.month-1]} ${date.year} \n ${formatDateToHourAndMinutes(date)}";
}
String formatDateToShortDate(DateTime date){
  return "${date.day} ${kMonths[date.month-1].substring(0,3)} ${date.year}";
}

/// Formats a DateTime value to a String showing the Day 
/// e.g: "Joi, 9 Iunie"
String? formatDateToDay(DateTime? date){
  return date != null
  ? kWeekdays[DateFormat('EEEE').format(date).substring(0,3)]! + ", " + date.day.toString() + " " + kMonths[date.month-1]
  : "";
}


String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
}

String? formatDateToHourAndMinutes(DateTime? date){
  return date != null
  ? (date.hour > 9 ? date.hour.toString() : "0" + date.hour.toString()) + ":" + (date.minute != 0 ? date.minute.toString() : "00")
  : "";
}

String formatDurationToHoursAndMinutes(Duration duration){
  return duration.inHours.toString() == "0"
  ?  "${duration.inMinutes}m"
  : "${duration.inHours}h ${duration.inMinutes%60}m";
}