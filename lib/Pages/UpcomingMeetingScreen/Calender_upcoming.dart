import 'package:flutter/material.dart';
import 'package:sial_app/model/Meeting.dart';
import 'package:sial_app/model/Meeting_data_source.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:timezone/data/latest.dart' as tz;

class CalenderWidget extends StatefulWidget {
  const CalenderWidget({Key? key}) : super(key: key);

  @override
  State<CalenderWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalenderWidget> {
  final folio = GetStorage().read('folio');

  Future<List<Meeting>> _getDataSource() async {
    final url = Uri.parse(
        'https://erm.scarletsystems.com:1050/Api/UPComAgenda/GetAll?folno=$folio');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final meetings = data.map((item) {
        final mdate = DateTime.parse(item['mdate']);
        final mtime = item['mtime']; // Extract the time value without parsing
        final committe =
            item['committe']; // Extract the time value without parsing
        final venue = item['venue']; // Extract the time value without parsing
        final meettime =
            item['meettime']; // Extract the time value without parsing
        // Check if the time string is in 'h:mm a' format or 'HH:mm' format
        final is24HourFormat =
            mtime.length == 5; // 'HH:mm' format is 5 characters long

        final parsedTime = is24HourFormat
            ? DateFormat('HH:mm')
                .parse(mtime) // Use 'HH:mm' pattern for 24-hour format
            : DateFormat('h:mm a').parse(
                mtime); // Use 'h:mm a' pattern for 12-hour format// Parse the time separately
        final meetingStartTime = DateTime(mdate.year, mdate.month, mdate.day,
            parsedTime.hour, parsedTime.minute);
        final meetingEndTime = meetingStartTime.add(Duration(hours: 2));
        return Meeting(
            item['tid'],
            item['meeting'],
            meetingStartTime,
            meetingEndTime,
            Color.fromARGB(255, 28, 44, 92),
            false,
            mtime,
            committe,
            venue,
            meettime);
      }).toList();

      return meetings;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'SIAL Corporate Affairs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _getDataSource(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfCalendar(
              appointmentBuilder:
                  (context, CalendarAppointmentDetails details) {
                List<Meeting> meetings = details.appointments
                    .map((appointment) => appointment as Meeting)
                    .toList();
                final String comName =
                    meetings.isNotEmpty ? meetings[0].comName : '';

                final String venue =
                    meetings.isNotEmpty ? meetings[0].venue : '';

                final String startTime =
                    meetings.isNotEmpty ? meetings[0].mtime.toString() : '';

                final String endTime =
                    meetings.isNotEmpty ? meetings[0].to.toString() : '';
                final String meetTime =
                    meetings.isNotEmpty ? meetings[0].meettime : '';

                return Container(
                  height: MediaQuery.of(context).size.height * 1,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  color: Theme.of(context).colorScheme.primary,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Committee: $comName',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Venue: $venue',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Time: $startTime',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              appointmentTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              todayHighlightColor: Theme.of(context).colorScheme.primary,
              view: CalendarView.month,
              cellBorderColor: Colors.transparent,
              dataSource: MeetingDataSource(snapshot.data!),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode:
                    MonthAppointmentDisplayMode.indicator,
                showAgenda: true,
              ),
            );
          } else if (snapshot.hasError) {
            //debugPrint(snapshot.error);
            return Center(child: Text('Something went wrong'));
          } else {
            return Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.primary,
              ),
            ));
          }
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_catalog/model/Meeting.dart';
// import 'package:flutter_catalog/model/Meeting_data_source.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../services/noti_service.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

// class CalenderWidget extends StatefulWidget {
//   const CalenderWidget({Key? key}) : super(key: key);

//   @override
//   State<CalenderWidget> createState() => _CalendarWidgetState();
// }

// class _CalendarWidgetState extends State<CalenderWidget> {
//   Future<List<Meeting>> _getDataSource() async {
//     final url = Uri.parse('https://erm.scarletsystems.com:1050/Api/UPComAgenda/GetAll/');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List<dynamic>;
//       final meetings = data.map((item) {
//         final mdate = DateTime.parse(item['mdate']);
//         final mtime = DateFormat('h:mm a').parse(item['mtime']);
//         return Meeting(
//           item['tid'],
//           item['meeting'],
//           DateTime(
//               mdate.year, mdate.month, mdate.day, mtime.hour, mtime.minute),
//           DateTime(mdate.year, mdate.month, mdate.day, mtime.hour, mtime.minute)
//               .add(Duration(hours: 2)),
//           Color.fromARGB(255, 28, 44, 92),
//           false,
//           item['mtime'],
//         );
//       }).toList();
//       // Schedule notifications for each meeting

//       // for (final meeting in meetings) {
//       //   final notificationDate = tz.TZDateTime.from(meeting.to, tz.local);
//       //   print('Scheduling notification for meeting ${meeting.tid}');
//       //   print('Notification date: $notificationDate');
//       //   NotificationService().showNotification(
//       //     meeting.tid, // Use the meeting ID as a unique identifier
//       //     'Meeting Reminder',
//       //     'Upcoming meeting: ${meeting.EventName}',
//       //     notificationDate,
//       //   );
//       // }

//       return meetings;
//     } else {
//       throw Exception('Failed to load meetings');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//   }

//   Future<void> _testNotification() async {
//     // Schedule a notification for 5 seconds from now
//     final now = tz.TZDateTime.now(tz.local);
//     final scheduleTime = now.add(Duration(seconds: 5));
//     NotificationService().showNotification(
//         0, // Use a unique identifier for the notification
//         'Test Notification',
//         'This is a test notification',
//         scheduleTime,
//         '3:99999');

//     // Display a SnackBar widget to confirm that the notification has been scheduled
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Test notification scheduled'),
//         duration: Duration(seconds: 5),
//       ),
//     );
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(onPressed: _testNotification),
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         title: Text(
//           'SIAL Corporate Affairs',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Meeting>>(
//         future: _getDataSource(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return SfCalendar(
//               appointmentTextStyle:
//                   TextStyle(color: Theme.of(context).colorScheme.primary),
//               todayHighlightColor: Theme.of(context).colorScheme.primary,
//               view: CalendarView.month,
//               cellBorderColor: Colors.transparent,
//               dataSource: MeetingDataSource(snapshot.data!),
//               monthViewSettings: MonthViewSettings(
//                 appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
//                 showAgenda: true,
//               ),
//             );
//           } else if (snapshot.hasError) {
//             print(snapshot.error);
//             return Center(child: Text('Something went wrong'));
//           } else {
//             return Center(
//                 child: CircularProgressIndicator.adaptive(
//               valueColor: AlwaysStoppedAnimation(
//                 Theme.of(context).colorScheme.primary,
//               ),
//             ));
//           }
//         },
//       ),
//     );
//   }
// }
