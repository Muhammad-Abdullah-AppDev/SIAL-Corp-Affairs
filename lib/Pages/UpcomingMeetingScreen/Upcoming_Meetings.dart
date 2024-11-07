import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sial_app/Pages/UpcomingMeetingScreen/upcomming_agenda_dtl.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../model/upcomming_meeting_model.dart';

class UpComingAgendaMeeting extends StatefulWidget {
  // const MyWidget({super.key});

  @override
  State<UpComingAgendaMeeting> createState() => _UpComingAgendaMeetingState();
}

class _UpComingAgendaMeetingState extends State<UpComingAgendaMeeting> {
  var folioNo;
  late int agendaId;

  Future<List<UpComingMeetingModel>> getAgendaMeetings() async {
    try {
      final response = await http.get(Uri.parse(
          'https://erm.scarletsystems.com:1050/Api/UPComAgenda/GetAll?folno=$folioNo'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        debugPrint('api hit####');
        return jsonList
            .map((json) => UpComingMeetingModel.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load data from API");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  List<UpComingMeetingModel> groupAndCombineAgendaData(
      List<UpComingMeetingModel> agendaList) {
    Map<String, List<UpComingMeetingModel>> groupedAgendaData = {};

    for (var agenda in agendaList) {
      final key = '${agenda.tid}_${agenda.mdate}';
      if (!groupedAgendaData.containsKey(key)) {
        groupedAgendaData[key] = [agenda];
      } else {
        groupedAgendaData[key]!.add(agenda);
      }
    }

    List<UpComingMeetingModel> combinedAgendaData = [];

    // Combine the committee names for each group
    groupedAgendaData.forEach((key, value) {
      String committeeNames =
          value.map((agenda) => agenda.committe ?? "").toSet().join(', ');

      // Get the first AgendaMeetimgModel from the group and update its "committe" value
      var firstAgenda = value.first;
      firstAgenda.committe = committeeNames;
      combinedAgendaData.add(firstAgenda);
    });

    // Sort the combinedAgendaData by mdate
    combinedAgendaData.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a.mdate!);
      DateTime dateTimeB = DateTime.parse(b.mdate!);
      return dateTimeA.compareTo(dateTimeB);
    });

    return combinedAgendaData;
  }

  @override
  void initState() {
    super.initState();
    folioNo = GetStorage().read("folio");
    debugPrint("folno:$folioNo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text('SIAL Corporate Affairs'),
      ),
      body: FutureBuilder<List<UpComingMeetingModel>>(
        future: getAgendaMeetings(),
        builder: (context, AsyncSnapshot<List<UpComingMeetingModel>> snapshot) {
          if (snapshot.hasData) {
            final agenda = snapshot.data;
            final combinedAgendaData =
                groupAndCombineAgendaData(agenda!); // Group and combine data
            return Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.only()),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
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
                                'Upcoming Agenda Meeting',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Meetings',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.more_horiz,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  )
                                ],
                              ),
                            ),
                            Divider(
                              indent: 22,
                              endIndent: 22,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 2.h),
                            Expanded(
                              child: combinedAgendaData.isEmpty
                                  ? Center(
                                      child: Text('No data found!'),
                                    )
                                  : ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: combinedAgendaData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final upcomingAgenda =
                                            combinedAgendaData[index];
                                        debugPrint(
                                            'Total Items: ${combinedAgendaData.length}');
                                        debugPrint(
                                            'Agenda tid : ${upcomingAgenda.tid.toString()}');
                                        debugPrint(
                                            'Agenda fkcmt Id : ${upcomingAgenda.fkcmt.toString()}');
                                        debugPrint(
                                            'Committee Name: ${upcomingAgenda.committe}');

                                        final dateFormat =
                                            DateFormat('dd-MMM-yyyy');

                                        final dateString =
                                            upcomingAgenda.mdate.toString();
                                        final date = DateTime.parse(dateString);
                                        final formattedDate =
                                            dateFormat.format(date);
                                        debugPrint('Date : $formattedDate');
                                        debugPrint(
                                            'Venue : ${upcomingAgenda.venue.toString()}');

                                        return GestureDetector(
                                          onTap: () {
                                            Get.to(() =>
                                                UpCommingAgendaMeetingDetail(
                                                  agendaName: upcomingAgenda.committe
                                                      .toString(),
                                                  tid: int.parse(upcomingAgenda
                                                      .tid
                                                      .toString()),
                                                  zoomlink:
                                                      upcomingAgenda.zM_LINK,
                                                  mdate: upcomingAgenda.mdate,
                                                  mid: upcomingAgenda.fkcmt,
                                                ));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(1.h),
                                            child: Container(
                                              padding: EdgeInsets.all(1.h),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            //Title
                                                            Text(
                                                              upcomingAgenda
                                                                          .committe
                                                                          ?.isEmpty ??
                                                                      true
                                                                  ? 'No committe found'
                                                                  : upcomingAgenda
                                                                      .committe!,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 10.sp,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary,
                                                              ),
                                                            ),
                                                            SizedBox(height: 3),
                                                            //Subtitle
                                                            Center(
                                                              child: Text.rich(
                                                                  TextSpan(
                                                                      text:
                                                                          'Date: ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimary,
                                                                        fontSize:
                                                                            10.sp,
                                                                      ),
                                                                      children: <InlineSpan>[
                                                                    TextSpan(
                                                                      text:
                                                                          "$formattedDate  Time: ${upcomingAgenda.mtime} ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10.sp,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimary,
                                                                      ),
                                                                    ),
                                                                  ])),
                                                            ),
                                                            SizedBox(height: 3),

                                                            Text(
                                                              'Venue:  ${upcomingAgenda.venue.toString()}',
                                                              style: TextStyle(
                                                                fontSize: 10.sp,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            //debugPrint(snapshot.error);
            return Center(child: Text('Something went wrong ..server error'));
          } else {
            return Center(
                child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                Color.fromARGB(255, 28, 44, 92),
              ),
            ));
          }
        },
      ),
    );
  }
}
