import 'package:flutter/cupertino.dart';
import 'package:sial_app/model/Meeting.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].EventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].Background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  String getCommitteeName(int index) {
    return appointments![index].comName;
  }

  String getVenue(int index) {
    return appointments![index].venue;
  }
}
// class MeetingDataSource extends CalendarDataSource {
//   MeetingDataSource(List<Meeting> source) {
//     appointments = source;
//   }
//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].from;
//   }

//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].to;
//   }

//   @override
//   String getSubject(int index) {
//     return appointments![index].EventName;
//   }

//   @override
//   Color getColor(int index) {
//     return appointments![index].Background;
//   }

//   @override
//   bool isAllDay(int index) {
//     return appointments![index].isAllDay;
//   }
// }
