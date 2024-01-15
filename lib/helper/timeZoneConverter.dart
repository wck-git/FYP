import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimeZoneConverterHelper {
  static DateTime convertUtcToMYTime(DateTime dbDateTime) {
    if (isMYTimeZone()) {
      return dbDateTime;
    }

    tz.initializeTimeZones();
    tz.Location myTimeZone = tz.getLocation('Asia/Kuala_Lumpur');
    DateTime dateTime = dbDateTime;
    tz.TZDateTime myTzDateTime = tz.TZDateTime.from(dateTime, myTimeZone);

    // convert TZDateTime to DateTime
    DateTime myDateTime = DateTime(
      myTzDateTime.year,
      myTzDateTime.month,
      myTzDateTime.day,
      myTzDateTime.hour,
      myTzDateTime.minute,
      myTzDateTime.second,
      myTzDateTime.millisecond,
      myTzDateTime.microsecond,
    );

    return myDateTime;
  }

  static Duration getTimeOffset() {
    // user timezone offset
    DateTime userDateTime = DateTime.now();
    Duration userTimeZoneOffset = userDateTime.timeZoneOffset;

    // malaysia timezone offset
    Duration malaysiaTimeZoneOffset = const Duration(hours: 8);

    Duration diffOffset = userTimeZoneOffset - malaysiaTimeZoneOffset;

    return diffOffset;
  }

  static DateTime subtractOffset(DateTime dateTime) {
    if (isMYTimeZone()) {
      return dateTime;
    }

    Duration diffOffset = getTimeOffset();
    int offsetHours = diffOffset.inHours;
    int offsetMins = diffOffset.inMinutes - offsetHours * 60;

    dateTime = dateTime.add(Duration(hours: offsetHours, minutes: offsetMins));

    return dateTime;
  }

  static bool isMYTimeZone() {
    Duration diffOffset = getTimeOffset();
    return diffOffset.inMilliseconds == 0;
  }
}
