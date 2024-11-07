import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../model/mom_model.dart';
import '../../model/yearModel.dart';
import 'mom_dtl.dart';

class MofMeeting extends StatefulWidget {
  @override
  State<MofMeeting> createState() => _MofMeetingPageState();
}

class _MofMeetingPageState extends State<MofMeeting> {
  var folioNo;
  List<MomModel> agendaList = [];
  List<MomModel> agendaData = [];
  bool isLoading = true;
  var selectedYear;

  TextEditingController searchController = TextEditingController();
  bool isFocused = false;
  String searchField = ' Search Here...';
  String searchText = '';

  List<YearModel> years = [];
  DateTime? fromDate;
  DateTime? toDate;
  String getCurrentYear() {
    final currentYear = DateTime.now().year;
    return currentYear.toString().substring(2); // Extract last two digits
  }

  @override
  void initState() {
    super.initState();
    folioNo = GetStorage().read("folio");
    debugPrint("folno:$folioNo");
    fetchYears();
    this.fetchAgenda();
    selectedYear = getCurrentYear();
  }

  Future<void> fetchYears() async {
    final response = await http.get(
        Uri.parse('https://erm.scarletsystems.com:1050/Api/GetYears/GetAll/'));

    if (response.statusCode == 200) {
      debugPrint('# Get Years ..Api hit Successfully: ${response.statusCode}');

      final jsonResponse = jsonDecode(response.body);
      setState(() {
        years = List.from(jsonResponse)
            .map((year) => YearModel.fromJson(year))
            .toList();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      Get.snackbar('Error', "Server error please try lator",
          duration: Duration(seconds: 5), snackPosition: SnackPosition.BOTTOM);
      debugPrint('Failed to load years: ${response.statusCode}');
    }
  }

  Future<void> fetchAgenda() async {
    try {
      var request = await http.Request(
          'GET',
          Uri.parse(
              'https://erm.scarletsystems.com:1050/Api/MOM/GetAll?folno=$folioNo'));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var jsonString = await response.stream.bytesToString();
        var decodedData = json.decode(jsonString);

        // Clear agendaData before adding new data
        agendaData.clear();

        decodedData.forEach((json) {
          MomModel agenda = MomModel.fromJson(json);
          agendaData.add(agenda);
        });

        // Apply filtering on agendaData based on the selected year (default value)
        if (selectedYear != null) {
          int yearIndex =
              years.indexWhere((year) => year.pkcode == selectedYear);
          if (yearIndex != -1) {
            fromDate = years[yearIndex].frdt;
            toDate = years[yearIndex].todt;
          }

          // Filter the agendaData list based on the selected year
          agendaList = agendaData.where((agenda) {
            if (agenda.mdate == null) return false;
            DateTime? agendaDate = DateTime.tryParse(agenda.mdate!);
            return agendaDate != null &&
                (fromDate == null || agendaDate.isAfter(fromDate!)) &&
                (toDate == null || agendaDate.isBefore(toDate!));
          }).toList();
        } else {
          agendaList = List.from(agendaData);
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          agendaList = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching agenda: $e');
      setState(() {
        isLoading = false;
        agendaList = [];
      });
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
              child: SpinKitFadingCube(
                color: Theme.of(context).colorScheme.primary,
                size: 50,
                duration: Duration(milliseconds: 600),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Container(
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
                                  'Mintues of Meeting',
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
                        Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                isFocused = hasFocus;
                              });
                            },
                            child: TextFormField(
                              controller: searchController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: isFocused
                                      ? ' Enter Search Keyword'
                                      : searchField,
                                  filled: true),
                              onChanged: (String? value) {
                                debugPrint("Search Value : $value");
                                setState(() {
                                  searchText = value.toString();
                                });
                              },
                            )),
                        SizedBox(height: 5),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedYear,
                          hint: Text('Search data by year'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue;
                              debugPrint(
                                  'selected year pkcode...$selectedYear');

                              // Update the fromDate and toDate based on the selectedYear
                              if (newValue != null) {
                                int yearIndex = years.indexWhere(
                                    (year) => year.pkcode == newValue);
                                if (yearIndex != -1) {
                                  fromDate = years[yearIndex].frdt;
                                  toDate = years[yearIndex].todt;
                                }
                                debugPrint('fromdate...$fromDate');
                                debugPrint('tomdate...$toDate');

                                // Filter the momData list based on the selected year
                                agendaList = agendaData.where((mom) {
                                  if (mom.mdate == null) return false;
                                  DateTime momDate =
                                      DateTime.parse(mom.mdate.toString());
                                  return momDate.isAfter(fromDate!) &&
                                      momDate.isBefore(toDate!);
                                }).toList();

                                // Group the filteredMomData by a unique key (combination of "tid" and "mdate")
                                if (agendaList != null) {
                                  Map<String, List<MomModel>> groupedMomData =
                                      {};

                                  for (var agenda in agendaList) {
                                    final key = '${agenda.tid}_${agenda.mdate}';
                                    if (!groupedMomData.containsKey(key)) {
                                      groupedMomData[key] = [agenda];
                                    } else {
                                      groupedMomData[key]!.add(agenda);
                                    }
                                  }

                                  // Combine the committee names for each group
                                  List<MomModel> combinedMomData = [];
                                  groupedMomData.forEach((key, value) {
                                    String committeeNames = value
                                        .map((mom) => mom.commite!)
                                        .toSet()
                                        .join(', ');

                                    // Get the first MomModel from the group and update its "commite" value
                                    var firstMom = value.first;
                                    firstMom.commite = committeeNames;
                                    combinedMomData.add(firstMom);
                                  });

                                  // Assign the combinedMomData back to filteredMomData
                                  agendaList = combinedMomData;
                                }
                              } else {
                                // If no year is selected, reset filteredMomData to show all data
                                agendaList = agendaData;
                              }
                            });
                          },
                          items: years.map<DropdownMenuItem<String>>(
                            (YearModel year) {
                              return DropdownMenuItem<String>(
                                value: year.pkcode,
                                child: Text(year.name),
                              );
                            },
                          ).toList(),
                          padding: EdgeInsets.only(left: 10),
                          borderRadius: BorderRadius.circular(10.0),
                          dropdownColor: Colors.grey.shade300,
                        ),
                        SizedBox(height: 1.h),
                        getList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget getList() {
    // Display loading spinner while data is being fetched
    if (isLoading) {
      return Center(
        child: SpinKitFadingCube(
          color: Theme.of(context).colorScheme.primary,
          size: 50,
          duration: Duration(milliseconds: 600),
        ),
      );
    }

    // Apply filtering on agendaData based on the selected year (default value)
    if (selectedYear != null) {
      int yearIndex = years.indexWhere((year) => year.pkcode == selectedYear);
      if (yearIndex != -1) {
        fromDate = years[yearIndex].frdt;
        toDate = years[yearIndex].todt;
      }

      // Filter the agendaData list based on the selected year
      agendaList = agendaData.where((agenda) {
        if (agenda.mdate == null) return false;
        DateTime? agendaDate = DateTime.tryParse(agenda.mdate!);
        return agendaDate != null &&
            (fromDate == null || agendaDate.isAfter(fromDate!)) &&
            (toDate == null || agendaDate.isBefore(toDate!));
      }).toList();
      // Sort the agendaList by mdate in a custom order
      agendaList.sort((a, b) {
        DateTime dateTimeA = DateTime.tryParse(a.mdate!) ?? DateTime(0);
        DateTime dateTimeB = DateTime.tryParse(b.mdate!) ?? DateTime(0);

        // Sort in descending order (newest first)
        return dateTimeB.compareTo(dateTimeA);
      });
      // Group and combine the filtered agendaList by a unique key (combination of "tid" and "mdate")
      Map<String, MomModel> groupedAgendaData = {};

      for (var agenda in agendaList) {
        final key = '${agenda.tid}_${agenda.mdate}';
        if (!groupedAgendaData.containsKey(key)) {
          groupedAgendaData[key] = agenda;
        } else {
          // Use a Set to store unique committee names
          Set<String> committeeNames = Set<String>();
          committeeNames
              .addAll(groupedAgendaData[key]?.commite?.split(',') ?? []);
          committeeNames.addAll(agenda.commite?.split(',') ?? []);

          // Combine the unique committee names into a single string
          groupedAgendaData[key]?.commite = committeeNames.join(', ');
        }
      }

      // Create a list to hold the grouped agenda data
      List<MomModel> groupedAgendaList = groupedAgendaData.values.toList();

      // Sort the groupedAgendaList by mdate in descending order (newest first)
      groupedAgendaList.sort((a, b) {
        DateTime dateTimeA = DateTime.tryParse(a.mdate!) ?? DateTime(0);
        DateTime dateTimeB = DateTime.tryParse(b.mdate!) ?? DateTime(0);
        return dateTimeB.compareTo(dateTimeA);
      });

      // Assign the groupedAgendaList back to agendaList
      agendaList = groupedAgendaList.toSet().toList();
    } else {
      agendaList = List.from(agendaData);
    }

    return Expanded(
      child: agendaList.isEmpty
          ? Center(
              child: Text(
                "No Data Found!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          //     ? Column(
          //   children: [
          //     Text(
          //       'Searching Data',
          //       style: TextStyle(
          //         fontSize: 16,
          //         color: Theme.of(context).colorScheme.primary,
          //         // fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //     SizedBox(height: 100,),
          //     CircularProgressIndicator(),
          //   ],
          // )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: agendaList.length,
              itemBuilder: (context, index) {
                final agendaData = agendaList[index];
                debugPrint("List Data: ${agendaData.commite}");
                late String committee = agendaData.commite.toString();
                late String venuee = agendaData.venue.toString();
                late String date = agendaData.mdate.toString();
                late String time = agendaData.mtime.toString();
                late String agendaDtl = agendaData.agendadtl.toString();
                late String momItem = agendaData.momfotitem.toString();
                late String momDtl = agendaData.momfotdtl.toString();
                DateTime datetime = DateTime.parse(date);
                String formatDate = DateFormat.yMMMEd().format(datetime);
                if (searchController.text.isEmpty) {
                  return getCard(agendaList[index]);
                } else if (committee
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    venuee
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    formatDate
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    time
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    agendaDtl
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    momItem
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase()) ||
                    momDtl
                        .toString()
                        .toLowerCase()
                        .contains(searchController.text.toLowerCase())) {
                  return getSearchCard(
                      agendaList[index], committee, venuee, formatDate, time);
                } else {
                  return Container();
                }
              },
            ),
    );
  }

  Widget getSearchCard(MomModel agenda, String committee, String venuee,
      String formatDate, String time) {
    var agendaName = agenda.meeting;
    int tid = agenda.tid!;
    // var mdate = agenda.mdate;
    // DateTime dateTime = DateTime.parse(mdate!);
    // String formatdate = DateFormat.yMMMEd().format(dateTime);
    // var venu = agenda.venue;
    // var committe = agenda.commite;
    // var zoomLink = agenda.;
    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: EdgeInsets.all(0.2.h),
        child: ListTile(
          onTap: () {
            Get.to(
              () => MintuesOfMeetingDetails(
                agendaName: agendaName!,
                tid: tid,
              ),
              // transition: Transition.leftToRightWithFade,
            );
          },
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$committee',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Date : $formatDate   Time:  $time',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Venue : $venuee',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 0.w),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 201, 203, 242),
                  borderRadius: BorderRadius.circular(0.8.h),
                ),
                child: Center(child: Icon(Icons.arrow_forward_ios)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getCard(MomModel agenda) {
    var agendaName = agenda.meeting;
    int tid = agenda.tid!;
    var mdate = agenda.mdate;
    DateTime dateTime = DateTime.parse(mdate!);

    String formatdate = DateFormat.yMMMEd().format(dateTime);
    var venu = agenda.venue;
    var committe = agenda.commite;
    // var zoomLink = agenda.;

    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      child: Padding(
        padding: EdgeInsets.all(0.2.h),
        child: ListTile(
          onTap: () {
            Get.to(
              () => MintuesOfMeetingDetails(
                agendaName: agendaName!,
                tid: tid,
              ),
              // transition: Transition.leftToRightWithFade,
            );
          },
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$committe',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Date : $formatdate   Time:  ${agenda.mtime}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      'Venue : $venu',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Text(
                    //   'Reference : $agendaName',
                    //   style: TextStyle(
                    //     color: Theme.of(context).colorScheme.onPrimaryContainer,
                    //     fontSize: 10.sp,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    //   // overflow: TextOverflow.ellipsis,
                    //   maxLines: 3,
                    // ),
                  ],
                ),
              ),
              SizedBox(width: 0.w),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 201, 203, 242),
                  borderRadius: BorderRadius.circular(0.8.h),
                ),
                child: Center(child: Icon(Icons.arrow_forward_ios)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
