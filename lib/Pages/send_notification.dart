import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../model/upcomming_meeting_model.dart';
import '../services/noti_service.dart';

class SendNotification extends StatefulWidget {
  const SendNotification({super.key});

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {

  List<String> deviceTokenListData = [];
  List commiteeList = [];
  var committeeMember = [];
  var folno;
  var selectedValue;
  var bodytext;
  var pkcoddeValue;
  NotificationService notificationService = NotificationService();

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    await Firebase.initializeApp();
    print(message.notification!.title.toString());
    print(message.notification!.body.toString());
    print(message.data.toString());
  }

  void initState() {

    folno = GetStorage().read('folio');

    super.initState();

    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.getDeviceToken().then((value) {
      debugPrint('Device Token : ');
      debugPrint(value);
    });
  }

  fetchCommitteMember(pkcoddeValue) async {
    var request = await http.Request(
        'GET',
        Uri.parse(
            'https://erm.scarletsystems.com:1050/Api/ComMem/GetById?pkcode=$pkcoddeValue'));
    debugPrint('pkcode: $pkcoddeValue');
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('hit committee member api ');
      setState(() {
        committeeMember = items;
        debugPrint('Total Member: ${committeeMember.length}');
        debugPrint('Total Member: ${committeeMember[0]['shname']}');
      });
      for(int i = 0; i < committeeMember.length; i ++) {

        debugPrint('Committee Member Detail:  ${committeeMember[i]['dtoken'].toString()}');

        String dToken = committeeMember[i]['dtoken'].toString();
        debugPrint('Device Tokens:  ${dToken}');
        deviceTokenListData.add(dToken);
      }
      debugPrint('Device Tokens:  ${deviceTokenListData}');
    } else {
      setState(() {
        committeeMember = [];
      });
    }
  }

  Future<List<UpComingMeetingModel>> getAgendaMeetings() async {
    try {
      final response = await http.get(Uri.parse(
          'https://erm.scarletsystems.com:1050/Api/UPComAgenda/GetAll?folno=$folno'));
      debugPrint('folio no is: $folno');
      final body = json.decode(response.body) as List;
      if(response.statusCode == 200){
        setState(() {
          commiteeList = body;
          //debugPrint("listReturned:$commiteeList");
        });
        return body.map((e){
          final map = e as Map<String, dynamic>;
          return UpComingMeetingModel(
              fkcmt:    map['fkcmt'],
              committe: map['committe'],
              venue:    map['venue'],
              meettime: map['meettime'],
          );
        }).toList();
      }
      else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // Future<List<CommitteeListModel>> fetchAgendaData() async {
  //   try {
  //     final response = await http.get(
  //         Uri.parse(
  //             'https://erm.scarletsystems.com:1050/Api/CommitteType/GetAll?folno=$folno'));
  //     debugPrint('folio no is: $folno');
  //     final body = json.decode(response.body) as List;
  //     if(response.statusCode == 200){
  //       setState(() {
  //         commiteeList = body;
  //         //debugPrint("listReturned:$commiteeList");
  //       });
  //       return body.map((e){
  //         final map = e as Map<String, dynamic>;
  //         return CommitteeListModel(
  //           pkcode: map['pkcode'],
  //           name: map['name'],
  //         );
  //       }).toList();
  //     }
  //   } catch (e){
  //     throw Exception('Error occured $e');
  //   }
  //   throw Exception('Error Fetching Data');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Selection'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              Image.asset('assets/images/app_icon.png'),
              FutureBuilder(
                future: getAgendaMeetings(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10), // Add padding here as needed
                        decoration: BoxDecoration(
                          color: Colors.white70, // Change the background color here
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [BoxShadow(
                            color: Colors.black,
                            spreadRadius: 3,
                            blurRadius: 4
                          )]
                        ),
                        child: DropdownButton(
                          dropdownColor: Colors.blueAccent,
                          hint: Text("Select Committee"),
                          isExpanded: true,
                          itemHeight: 50.0,
                          value: selectedValue,
                          items: snapshot.data!.map((e) {
                            return DropdownMenuItem(
                              value: e.fkcmt.toString() + " , " + e.committe.toString()+" Meeting on: "+e.meettime.toString(),
                              child: Text("${e.committe.toString()} [ ${e.meettime.toString()} ]"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedValue = value;
                            List<String> values = selectedValue.split(',');

                            if (values.length == 2) {
                              pkcoddeValue = values[0];
                              bodytext = values[1];

                              debugPrint('pkCode Value: $pkcoddeValue');
                              debugPrint('Second Value: $bodytext');
                            } else {
                              debugPrint('Invalid format: $selectedValue');
                            }

                            debugPrint('Selected Value is: $selectedValue');
                            setState(() {
                              fetchCommitteMember(pkcoddeValue);
                            });
                          },
                        ),
                      );
                    }else {
                      return CircularProgressIndicator();
                    }
                  }
              ),
              SizedBox(height: 35,),
              InkWell(
                onTap: (){
                  debugPrint('Tokens Amount: ${deviceTokenListData[3]}');

                  for(int i = 0; i < deviceTokenListData.length; i ++) {
                    debugPrint('Notification sent to Device Token: ${deviceTokenListData[i]}');
                    sendNotification(deviceTokenListData[i]);
                  }

                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(25.0)
                  ),
                  child: Center(
                    child: Text('Send Notification',
                    style: TextStyle(fontSize: 18,
                    color: Colors.white),),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  void sendNotification(deviceToken) async {
    var data = {
      'to': deviceToken,
      'priority': 'high',
      'notification': {
        'title': 'Meeting Reminder',
        'body': bodytext.toString(),
        'description': 'Open the app to see details'
      },
      'data': {
        'type': 'msg',
      }
    };
    await http.post(Uri.parse(
        'https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAPuzVVT8:APA91bH1W2AYYu5s5wD_TVnvZaw-8dwX_GOH_kcqv3XrrWrOkyWGd8LC5PKdP2Fd7bCBa5LYlcUH40Tr_TcVyu_EZCkzZoBWmpZwMqMP5mZfVt4oD9sH-Y9QbhSrOzT1HkD_3OlN0Azo',
        }
    );
    print('Notification send to: $deviceToken');
    print('Notification detail: ');
  }
}
