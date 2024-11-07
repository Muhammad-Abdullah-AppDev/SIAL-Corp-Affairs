import 'dart:async';
import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sial_app/Pages/AgendaScreen/Agenda_Meeting.dart';
import 'package:sial_app/Pages/FlightSchedule/departure_screen.dart';
import 'package:sial_app/Pages/UpcomingMeetingScreen/Calender_upcoming.dart';
import 'package:sial_app/Pages/MOMScreens/Mintues_of_Meeting.dart';
import 'package:sial_app/Pages/UpcomingMeetingScreen/Upcoming_Meetings.dart';
import 'package:sial_app/Pages/CommitteeScreen/CommitteListScreen.dart';
import 'package:sial_app/Pages/zoom_screen.dart';
import 'package:sial_app/services/noti_service.dart';
import 'package:sial_app/widgets/drawer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/upcomming_meeting_model.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  List<UpComingMeetingModel>? upcomingMeetings;
  bool dataLoaded = false;
  int timeDifference = 0;
  Timer? timer;

  var mId;
  var mFormatDate;
  var mTime;
  var mTitle;
  var mRmks;
  var mVenue;
  var mTotal;
  bool eventAdded = false;

  final folio = GetStorage().read('folio');
  var _box = GetStorage();

  getUpcomingMeetings() async {
    try {
      final response = await http.get(Uri.parse(
          'https://erm.scarletsystems.com:1050/Api/UPComAgenda/GetAll?folno=$folio'));

      if (response.statusCode == 200) {
        debugPrint("API hit successfully: ${response.statusCode}");
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert JSON data to UpComingMeetingModel objects
        List<UpComingMeetingModel> meetings = jsonList
            .map((json) => UpComingMeetingModel.fromJson(json))
            .toList();

        debugPrint('Total Meetings: ${meetings.length}');
        if (meetings.length > 0) {
          List<dynamic> addedEventsCheck = await _box.read('addedEvents') ?? ['-1'];
          debugPrint('Event Check Values: ${addedEventsCheck}');
          List<UpComingMeetingModel>? eventFilter = [];

          for (var meeting in meetings) {
            if (!addedEventsCheck.contains(meeting.tid)) {
              // If the meeting tid is not in addedEventsCheck, add it to the eventFilter list
              eventFilter.add(meeting);
              debugPrint('Printttttttttt---------------: ${meeting.tid}');
            }
          }
          debugPrint('Event Filter Value: ${eventFilter}');
          if (eventFilter == null || eventFilter.isEmpty) {
          } else {
            debugPrint('Event Ongoing Value: ${eventFilter.map((e) => e.tid)}');
            buildCalendarDialog(eventFilter);
          }
        }
        // Sort the meetings based on the mdate property
        meetings.sort((a, b) => a.mdate!.compareTo(b.mdate!));

        // for (var meeting in meetings) {
        //   debugPrint('Meeting Format Date is: ${mFormatDate}');
        //   debugPrint('Meeting Committe is: ${meeting.committe}');
        //   debugPrint('Meeting time is: ${meeting.mtime}');
        //   debugPrint("${DateTime.now()}");
        // }
        setState(() {
          upcomingMeetings = meetings;
          debugPrint("UPcoming MT DATA : ${upcomingMeetings![0].tid}");
          dataLoaded = true;
        });
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

// isMeetingToday method
  bool isMeetingToday(UpComingMeetingModel meeting) {
    if (meeting.mdate == null) {
      return false; // Return false if mdate is null (no meeting date available)
    }
    // Get the current date without the time part
    DateTime currentDate = DateTime.now();
    DateTime currentOnlyDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Parse the mDate string to a DateTime object and extract the date part
    DateTime meetingDate = DateTime.parse(meeting.mdate!).toLocal();
    DateTime meetingOnlyDate =
        DateTime(meetingDate.year, meetingDate.month, meetingDate.day);
    // Print the dates for debugging
    debugPrint('Current Date: $currentOnlyDate');
    debugPrint('Meeting Date: $meetingOnlyDate');
    // Compare the dates without the time part
    return currentOnlyDate == meetingOnlyDate;
  }

// buildAlertMethod
  Widget buildTodayMeetingAlert(List<UpComingMeetingModel> upcomingMeetings) {
    debugPrint('Upcoming Meetings: $upcomingMeetings');
    bool hasTodayMeeting = upcomingMeetings.any(isMeetingToday);
    debugPrint('Has Today Meeting: $hasTodayMeeting');

    if (hasTodayMeeting) {
      int todayMeetingIndex = upcomingMeetings.indexWhere(isMeetingToday);
      UpComingMeetingModel todayMeeting = upcomingMeetings[todayMeetingIndex];

      final currentTime = DateTime.now();
      final formatter = DateFormat("h:mm");

      // Check the length of mtime to determine the time format
      bool is24HourFormat = todayMeeting.mtime!.length ==
          5; // 'HH:mm' format is 5 characters long

      // Parse the mtime string using the appropriate pattern
      final formatedmtime = is24HourFormat
          ? DateFormat("HH:mm").parse(todayMeeting.mtime!)
          : formatter.parse(todayMeeting.mtime!);

      debugPrint("Current time: ${formatter.format(currentTime)}");
      debugPrint("Mtime formatted: ${formatter.format(formatedmtime)}");

      // Create a DateTime object for the current day with the time from formatedmtime
      DateTime currentTimeWithMtime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        formatedmtime.hour,
        formatedmtime.minute,
      );

      // Calculate the time difference in minutes
      timeDifference = currentTimeWithMtime.difference(currentTime).inMinutes;
      debugPrint('Time Difference Value: $timeDifference');
      final meetTime = todayMeeting.meettime;
      final timePart = meetTime
          ?.split(" ")[1]; // Split the string by space and get the second part

      debugPrint(
          "Meeting Time: ${meetTime?.replaceAll(timePart!, '').trim()} [${timePart}]");
      debugPrint("Meeting Time: ${todayMeeting.meettime.toString()}");

      // Check if the meeting is within 15 minutes from the current time
      if (timeDifference <= 15 && timeDifference >= -180) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 3.5,
                  blurRadius: 6.0,
                )
              ],
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 7.5.h,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today Meeting Alert',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          "Meeting Time: ${meetTime?.replaceAll(timePart!, '').trim()}  [${timePart}]",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //debugPrint(todayMeeting.tid);
                      debugPrint(" zoomLink:${todayMeeting.zM_LINK}");
                      Get.to(
                        () => ZoomScreen(
                          tid: todayMeeting.tid,
                          zoomLink: todayMeeting.zM_LINK,
                        ),
                        transition: Transition.leftToRightWithFade,
                      );
                    },
                    child: Text(
                      "Join Now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    // Return an empty container if there are no meetings today or the meeting is not within 15 minutes from the current time
    return Container();
  }

  //List<bool> eventAddedStatus = [];

  // Future<void> initializeEventAddedStatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   for (int i = 0; i < mId; i++) {
  //     bool added = prefs.getBool('$i') ?? false;
  //     setState(() {
  //       eventAddedStatus.add(added);
  //       debugPrint('Event Added Status: $eventAddedStatus');
  //     });
  //   }
  // }
  //
  // Future<void> markEventAsAdded(int index) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('$index', true);
  // }

  // Future<void> checkEventAddedStatus(int index) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     eventAdded = prefs.getBool('$index') ?? false;
  //     debugPrint("Shared Pref Data: ${prefs.getBool("$index")}");
  //   });
  // }

  Future<void> addEventToCalendar(
      List<UpComingMeetingModel> meetings, int i) async {
    List<dynamic> addedEvents = await _box.read('addedEvents') ?? ['-1'];
    debugPrint("Added Event Stored Values: ${_box.read("addedEvents")}");
    PermissionStatus status = await Permission.calendar.request();

    mId = meetings[i].tid;
    mTime = meetings[i].mtime;
    mTitle = meetings[i].committe;
    mVenue = meetings[i].venue;
    mRmks = meetings[i].rmks;
    String? dateTimeString = meetings[i].mdate;
    DateTime dateTime = DateTime.parse(dateTimeString!);
    mFormatDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    if (mId != null &&
        mFormatDate != null &&
        mTime != null &&
        mTitle != null &&
        mVenue != null &&
        mRmks != null) {
      DateTime startDate = DateTime.parse(mFormatDate + ' ' + mTime);

      if (status == PermissionStatus.granted) {
        //await checkEventAddedStatus(mId);
        // final bool isEventAdded = _prefs.getBool(mId.toString()) ?? false;
        if (addedEvents.contains(mId)) {
          Fluttertoast.showToast(
              msg: "Event ${i + 1} Already Added To Calendar",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Event event = Event(
            title: '$mTitle',
            description: '$mRmks',
            location: '$mVenue',
            startDate: startDate,
            endDate: startDate.add(Duration(hours: 3)),
            timeZone: DateTime.now().timeZoneName,
          );
          bool success = await Add2Calendar.addEvent2Cal(event);
          if (success) {
            debugPrint('Event added to calendar!');
            _box.write('addedEvents', [..._box.read('addedEvents'), mId]);
            debugPrint("Event Value: ${_box.read("addedEvents")}");
          } else {
            debugPrint('Failed to add event to calendar.');
          }
        }
        // } else {
        //   debugPrint("Event Aready Added");
        //   Fluttertoast.showToast(
        //       msg: "Event ${i+1} Already Added To Calendar",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.green,
        //       textColor: Colors.white,
        //       fontSize: 16.0
        //   );
        // }
      } else {
        debugPrint("Calendar Permission not granted");
        //await checkEventAddedStatus(mId);
        // final bool isEventAdded = await _prefs.getBool(mId.toString()) ?? false;
        // if (!isEventAdded) {
        if (addedEvents.contains(mId)) {
          Fluttertoast.showToast(
              msg: "Event ${i + 1} Already Added To Calendar",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Event event = Event(
            title: '$mTitle',
            description: '$mRmks',
            location: '$mVenue',
            startDate: startDate,
            endDate: startDate.add(Duration(hours: 3)),
            timeZone: DateTime.now().timeZoneName,
          );
          bool success = await Add2Calendar.addEvent2Cal(event);
          if (success) {
            debugPrint('Event added to calendar!');
            _box.write('addedEvents', [..._box.read('addedEvents'), mId]);
            debugPrint("Event Value: ${_box.read("addedEvents")}");
          } else {
            debugPrint('Failed to add event to calendar.');
          }
        }
        //});
        // } else {
        //   debugPrint("Aready Added");
        //   Fluttertoast.showToast(
        //       msg: "Event ${i+1} Already Added To Calendar",
        //       toastLength: Toast.LENGTH_SHORT,
        //       gravity: ToastGravity.BOTTOM,
        //       timeInSecForIosWeb: 1,
        //       backgroundColor: Colors.green,
        //       textColor: Colors.white,
        //       fontSize: 16.0
        //   );
        //}
      }
    } else {
      debugPrint("Some Values are Empty");
    }
  }

  Future<void> buildCalendarDialog(List<UpComingMeetingModel> meetings) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 20,
          shadowColor: Colors.indigo,
          //title: Text('${meetings.length} Meeting UpComing'),
          title: Column(
            children: [
              Text('Click Meeting Detail You Want To Add On Calendar',
                  style: TextStyle(fontSize: 18)),
              Divider(
                color: Colors.grey,
                indent: 10,
                endIndent: 10,
              )
            ],
          ),
          //content: Text('Add Them To Calendar'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.separated(
              physics: ScrollPhysics(),
              itemCount: meetings.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.transparent),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    addEventToCalendar(meetings, index);
                  },
                  child: Stack(children: [
                    Card(
                      elevation: 10,
                      color: Colors.greenAccent,
                      shadowColor: Colors.indigo,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${meetings[index].committe}"),
                            Text("${meetings[index].venue}"),
                            Text(
                              "${meetings[index].meettime}",
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // AnimatedSwitcher(
                    //   duration: Duration(seconds: 1),
                    //   child: Image.asset(
                    //     imagePaths[currentIndex],
                    //     key: Key(imagePaths[currentIndex]),
                    //     height: 20,
                    //     width: 10,
                    //   ),
                    //   transitionBuilder: (child, animation) {
                    //     return FadeTransition(
                    //       opacity: animation,
                    //       child: SlideTransition(
                    //         position: Tween<Offset>(
                    //           begin: Offset(-0.1, 0.0),
                    //           end: Offset.zero,
                    //         ).animate(animation),
                    //         child: child,
                    //       ),
                    //     );
                    //   },
                    // ),
                    Positioned(
                      right: 35,
                      bottom: 20,
                      child: Image.asset(
                        "assets/images/ad_click.png",
                        height: 30,
                        width: 20,
                        color: Colors.indigo,
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, // Background color
                foregroundColor: Colors.white, // Foreground color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
            // TextButton(
            //   onPressed: () {
            //   for (int i = 0; i < meetings.length; i++ ) {
            //     Timer(Duration(seconds: i==0 ? 0 : 5), () async {
            //       await addEventToCalendar(meetings, i);
            //     });
            //   }
            //   Navigator.pop(context);
            //   },
            //   child: Text(' Add Event '),
            // ),
          ],
        );
      },
    );
  }

  // Future<void> _initPrefs() async {
  //   _prefs = await SharedPreferences.getInstance();
  // }

  NotificationService notificationService = NotificationService();

  final List<String> imagePaths = [
    'assets/images/ad_click.png',
    'assets/images/flight.png'
  ];

  int currentIndex = 0;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % imagePaths.length;
      });
    });
  }

  @override
  void initState() {
    _startTimer();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.forward();

    getUpcomingMeetings().then((_) {
      // Check if there are no meetings today and update the UI
      bool hasTodayMeeting = upcomingMeetings!.any(isMeetingToday);
      if (!hasTodayMeeting) {
        setState(() {
          dataLoaded = true;
        });
      }
    });
    // Start the timer to update the UI every minute
    // timer = Timer.periodic(Duration(minutes: 1), (timer) {
    //   updateUI();
    // });

    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.foregroundMessage();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.getDeviceToken().then((value) {
      debugPrint('Device Token: ');
      debugPrint(value);
      updateDeviceToken(folio.toString(), value);
    });
    //calendarPermission();
  }

  Future<void> updateDeviceToken(String folno, String deviceToken) async {
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://erm.scarletsystems.com:1050/Api/Login/UpdateByid?folno=$folno&token=$deviceToken'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      debugPrint(await response.stream.bytesToString());
      debugPrint('Response success');
    } else {
      debugPrint(response.reasonPhrase);
      debugPrint('Response not/...');
    }
  }

  void updateUI() {
    setState(() {
      // Check if there are no meetings today, or the meeting is not within 15 minutes from the current time, or the meeting time has passed (timeDifference > 15).
      dataLoaded =
          !upcomingMeetings!.any(isMeetingToday) || timeDifference > 15;
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // event ad_click icon animation
    _animationController.dispose();
    // Cancel the timer to avoid memory leaks
    timer!.cancel();
    super.dispose();
  }

  DateTime? _lastTapTime;
  // Function to show the exit confirmation dialog
  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Exit App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        );
      },
    );
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    DateTime currentTime = DateTime.now();
    // If _lastTapTime is null or the difference between currentTime and _lastTapTime is greater than 2 seconds, reset the timer
    if (_lastTapTime == null ||
        currentTime.difference(_lastTapTime!) > Duration(seconds: 2)) {
      _lastTapTime = currentTime;
      _showExitDialog(context);
      return false; // Returning false will not exit the app
    } else {
      // Exiting the app using SystemNavigator.pop()
      SystemNavigator.pop();
      return true; // Returning true will exit the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        //home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'SIAL Corporate Affairs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: OrientationBuilder(builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? Container(
                    child: Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            SizedBox(height: 1.h),
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: TextButton(
                                          onPressed: () {
                                            Get.to(() => CalenderWidget(),
                                                transition: Transition
                                                    .leftToRightWithFade);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      spreadRadius: 2,
                                                      blurRadius: 1)
                                                ]),
                                            height: 7.3.h,
                                            width: double.infinity,
                                            child: _selectedAgend(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                "Upcoming Meetings",
                                                "Calender Wise",
                                                context),
                                          ),
                                        ),
                                      ),
                                      //SizedBox(height: 0.5.h),
                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: TextButton(
                                          onPressed: () {
                                            Get.to(() => AgendaMeeting(),
                                                transition: Transition
                                                    .leftToRightWithFade);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      spreadRadius: 2,
                                                      blurRadius: 1)
                                                ]),
                                            height: 7.3.h,
                                            width: double.infinity,
                                            child: _selectedAgend(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                "Total Meetings Over",
                                                " Years",
                                                context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              flex: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                color: Theme.of(context).colorScheme.onPrimary,
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 1.2,
                                  children: [
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(() => UpComingAgendaMeeting(),
                                              transition: Transition
                                                  .leftToRightWithFade);
                                        },
                                        // padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/DueAgenda.png',
                                            'Upcoming\nMeetings',
                                            Theme.of(context).colorScheme.error,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(() => AgendaMeeting(),
                                              transition: Transition
                                                  .leftToRightWithFade);
                                        },
                                        //padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/agenda.png',
                                            ' Agenda\nMeetings',
                                            Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(() => MofMeeting(),
                                              transition: Transition
                                                  .leftToRightWithFade);
                                        },
                                        child: _selectedExtras(
                                            'assets/images/Minutes-of-Meeting.png',
                                            'Minutes of\n  Meeting',
                                            Theme.of(context)
                                                .colorScheme
                                                .surfaceTint,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(() => CommitteeeListScreen(),
                                              transition: Transition
                                                  .leftToRightWithFade);
                                        },
                                        child: _selectedExtras(
                                            'assets/images/Committee.png',
                                            'Committees',
                                            Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Get.to(() => DepartureScreen());
                                        },
                                        //padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/flight.png',
                                            'Flight Schedule',
                                            Color(0xFF475c42),
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () async {
                                          await Future.delayed(
                                              Duration(milliseconds: 1));
                                          if (await canLaunch(
                                              "https://www.sial.com.pk/")) {
                                            await launch(
                                                "https://www.sial.com.pk/");
                                          }
                                        },
                                        //padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/website.png',
                                            'SIAL Website',
                                            Color(0xFF475c42),
                                            context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            //Show the container only if there are meetings today
                            upcomingMeetings != null && dataLoaded
                                ? buildTodayMeetingAlert(upcomingMeetings!)
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 1.h),
                            Expanded(
                              flex: 3,
                              child: Container(
                                // color: Colors.yellow,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CalenderWidget()));
                                          },
                                          child: Container(
                                            height: 7.h,
                                            width: double.infinity,
                                            child: _selectedAgend(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                "Upcoming Meetings",
                                                "Calender Wise",
                                                context),
                                          ),
                                        ),
                                      ),
                                      // ),
                                      SizedBox(height: 0.h),

                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AgendaMeeting()));
                                          },
                                          child: Container(
                                            height: 7.h,
                                            width: double.infinity,
                                            child: _selectedAgend(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                "Total Meetivngs Over",
                                                " Years",
                                                context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                color: Theme.of(context).colorScheme.onPrimary,
                                height: 4.h,
                                child: GridView.count(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  // childAspectRatio: 1.20,
                                  children: [
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpComingAgendaMeeting()));
                                        },
                                        // padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/DueAgenda.png',
                                            'Upcoming Meetings',
                                            Theme.of(context).colorScheme.error,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AgendaMeeting()));
                                        },
                                        //padding: const EdgeInsets.all(8.0),
                                        child: _selectedExtras(
                                            'assets/images/agenda.png',
                                            'Agenda Meetings',
                                            Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MofMeeting()));
                                        },
                                        child: _selectedExtras(
                                            'assets/images/Minutes-of-Meeting.png',
                                            'Minutes of Meeting',
                                            Theme.of(context)
                                                .colorScheme
                                                .inversePrimary,
                                            context),
                                      ),
                                    ),
                                    Container(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommitteeeListScreen()));
                                        },
                                        child: _selectedExtras(
                                            'assets/images/Committee.png',
                                            'Committees',
                                            Theme.of(context)
                                                .colorScheme
                                                .surfaceTint,
                                            context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Show the container only if there are meetings today

                            upcomingMeetings != null && dataLoaded
                                ? buildTodayMeetingAlert(upcomingMeetings!)
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
          }),
        ),

        drawer: MyDrawer(),
      ),
    );
  }

  Widget _selectedAgend(Color color, String title, String subtitle, context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 3.w),

      //height: 100,
      //  width: 260,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0.5.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _selectedExtras(String image, String name, Color color, context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 3,
              blurRadius: 6,
            )
          ],
          color: color,
          borderRadius: BorderRadius.circular(1.h),
          border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary, width: 1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 7.h,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(image)),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).colorScheme.onPrimary),
          ),

          //Color(Colors.green),
        ],
      ),
    );
  }
}
