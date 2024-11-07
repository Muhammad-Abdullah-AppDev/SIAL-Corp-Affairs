// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// import '../model/upcomming_meeting_model.dart';

// class HomeController extends GetxController {
//   List<UpComingMeetingModel>? upcomingMeetings;
//   bool dataLoaded = false;
//   UpComingMeetingModel? todayMeeting;

//   @override
//   void onInit() {
//     super.onInit();
//     getUpcomingMeetings();
//   }

//   Future<void> getUpcomingMeetings() async {
//     try {
//       final response = await http
//           .get(Uri.parse('http://194.116.228.5:130/Api/UPComAgenda/GetAll/'));

//       if (response.statusCode == 200) {
//         print("API hit successfully: ${response.statusCode}");
//         final List<dynamic> jsonList = json.decode(response.body);
//         upcomingMeetings = jsonList
//             .map((json) => UpComingMeetingModel.fromJson(json))
//             .toList();
//         dataLoaded = true;
//         update(); // Notify listeners about the data change
//         // updateTodayMeeting();
//       } else {
//         throw Exception("Failed to load data from API");
//       }
//     } catch (e) {
//       throw Exception("An error occurred: $e");
//     }
//   }

//   // void updateTodayMeeting() {
//   //   if (upcomingMeetings == null || upcomingMeetings!.isEmpty) {
//   //     todayMeeting = null;
//   //     return;
//   //   }

//   //   final currentTime = DateTime.now();
//   //   final formatter = DateFormat("h:mm a");

//   //   for (UpComingMeetingModel meeting in upcomingMeetings!) {
//   //     if (isMeetingToday(meeting)) {
//   //       final mtime = formatter.parse(meeting.mtime!);

//   //       DateTime currentTimeWithMtime = DateTime(
//   //         currentTime.year,
//   //         currentTime.month,
//   //         currentTime.day,
//   //         mtime.hour,
//   //         mtime.minute,
//   //       );

//   //       final timeDifference =
//   //           currentTimeWithMtime.difference(currentTime).inMinutes;
//   //       if (timeDifference >= 0 && timeDifference <= 15) {
//   //         todayMeeting = meeting;
//   //         return;
//   //       }
//   //     }
//   //   }

//   //   // If no meeting found, set todayMeeting to null
//   //   todayMeeting = null;
//   // }
//   bool isMeetingWithin15Minutes() {
//     if (todayMeeting == null) {
//       return false; // Return false if there is no meeting scheduled for today
//     }

//     final currentTime = DateTime.now();
//     final formatter = DateFormat("h:mm a");

//     final mtime = formatter
//         .parse(todayMeeting!.mtime!); // Parse the time from the API response

//     print("Current Time: ${currentTime.toString()}");
//     print("MTime: ${mtime.toString()}");

//     DateTime currentTimeWithMtime = DateTime(
//       currentTime.year,
//       currentTime.month,
//       currentTime.day,
//       mtime.hour,
//       mtime.minute,
//     );

//     final timeDifference =
//         currentTimeWithMtime.difference(currentTime).inMinutes;
//     print("Time Difference: $timeDifference");

//     return timeDifference >= 0 && timeDifference <= 15;
//   }

//   bool isMeetingToday(UpComingMeetingModel meeting) {
//     if (meeting.mdate == null) {
//       return false; // Return false if mdate is null (no meeting date available)
//     }

//     // Get the current date without the time part
//     DateTime currentDate = DateTime.now();
//     DateTime currentOnlyDate =
//         DateTime(currentDate.year, currentDate.month, currentDate.day);

//     // Parse the mDate string to a DateTime object
//     DateTime meetingDateTime = DateTime.parse(meeting.mdate!);

//     // Extract the date part of the meeting date without the time
//     DateTime meetingOnlyDate = DateTime(
//         meetingDateTime.year, meetingDateTime.month, meetingDateTime.day);

//     // Compare the dates without the time part
//     return currentOnlyDate == meetingOnlyDate;
//   }
// }
