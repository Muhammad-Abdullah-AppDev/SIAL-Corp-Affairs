import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CommitteeDetailsScreen extends StatefulWidget {
  CommitteeDetailsScreen({super.key, required this.tid, required this.name});
  int? tid;
  String? name;

  @override
  State<CommitteeDetailsScreen> createState() => _CommitteeDetailsScreenState();
}

class _CommitteeDetailsScreenState extends State<CommitteeDetailsScreen> {
  var committeeType = {};
  bool isLoading = false;

  var committeeMember = [];

  //// committeeMember api
  fetchCommitteMember() async {
    // print("fetching...");
    isLoading = true;
    var request = await http.Request(
        'GET',
        Uri.parse(
            'https://erm.scarletsystems.com:1050/Api/ComMem/GetById?pkcode=${widget.tid}'));
    debugPrint('pkcode: ${widget.tid}');
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('hit committee member api ');
      setState(() {
        isLoading = false;
        committeeMember = items;
        debugPrint('Total Member: ${committeeMember.length}');
        //debugPrint(committeeMember);
      });
    } else {
      setState(() {
        isLoading = false;
        committeeMember = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.fetchCommitteMember();
  }

/////////////////////////////
  // Define a custom sorting function to order the member types
  int getMemberTypePriority(String memberType) {
    switch (memberType) {
      case'Chairman':
        return 1;
      case'Vice Chairman':
        return 2;
      case 'Convener':
        return 3;
      case 'Senior Deputy Convener':
        return 4;
      case 'Deputy Convener':
        return 5;
      case 'Member':
        return 6;
      default:
        return 7;
    }
  }

  _makingPhoneCall({required number}) async {
    var url = Uri.parse("tel:$number");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await launchUrl(url);
    }
  }

  @override
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Container(
                  // height: 700,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.only()),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(1.5.h),
                                child: Text(
                                  '${widget.name}',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: committeeMember.length,
                            itemBuilder: (context, index) {
                              committeeMember.sort((a, b) {
                                // Sort the committee members based on their member type priority
                                final int priorityA =
                                    getMemberTypePriority(a['mtype']);
                                final int priorityB =
                                    getMemberTypePriority(b['mtype']);
                                return priorityA.compareTo(priorityB);
                              });
                              final names = committeeMember[index]['shname'];
                              final type = committeeMember[index]['mtype'];
                              final number = committeeMember[index]['mobilE_NO'];
                              debugPrint(
                                  'Member name: ${committeeMember[index]['shname']}');
                              debugPrint(
                                  'Member type: ${committeeMember[index]['mtype']}');
                              debugPrint(
                                  'Member fkcode: ${committeeMember[index]['fkcode']}');
                              debugPrint(
                                  'Member Phone No: ${committeeMember[index]['mobilE_NO']}');
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10),
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$names",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.sp,
                                        color: type == 'Member'
                                            ? Colors.black
                                            : Colors.green.shade700,
                                      ),
                                    ),
                                    Text(
                                      "$type",
                                      style: TextStyle(
                                        color: type == 'Member'
                                            ? Colors.black
                                            : Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 9.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}