import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../widgets/roundbutton.dart';
import '../MOMScreens/MOMByCom.dart';
import '../AgendaScreen/agendMeetingByComm.dart';
import 'commitee_details.dart';

class CommitteeeListScreen extends StatefulWidget {
  const CommitteeeListScreen({Key? key}) : super(key: key);

  @override
  State<CommitteeeListScreen> createState() => _CommitteeeListScreenState();
}

class _CommitteeeListScreenState extends State<CommitteeeListScreen> {
  List commiteeListMeember = [];
  bool isLoading = false;
  var folno;

  fetchAgenda() async {
    // print("fetching...");
    isLoading = true;

    var request = await http.Request(
        'GET',
        Uri.parse(
            'https://erm.scarletsystems.com:1050/Api/CommitteType/GetAll?folno=' +
                folno));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('api hit commitee List');
      setState(() {
        isLoading = false;

        commiteeListMeember = items;
        debugPrint("listReturned:$commiteeListMeember");
      });
    } else {
      setState(() {
        isLoading = false;

        commiteeListMeember = [];
      });
    }
  }

  //////////////////////////
  double screenHeight = 0;
  double screenWidth = 0;

  bool startAnimation = false;

  List<IconData> icons = [
    Icons.computer_outlined,
    Icons.savings,
    Icons.compare_arrows_outlined,
  ];

  @override
  void initState() {
    folno = GetStorage().read('folio');

    this.fetchAgenda();

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        startAnimation = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("folno:${folno}");
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

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
      // backgroundColor: Color.fromARGB(255, 44, 119, 94),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth / 28,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.all(1.5.h),
                            child: Text(
                              'Committee List',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (commiteeListMeember
                        .isEmpty) // Check if the list is empty
                      Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: commiteeListMeember.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return Container(
                                    height:
                                        300, // Set the specific height you want
                                    child: Center(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Text(
                                            'More Details',
                                            style: GoogleFonts.almendra(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 25),
                                          Center(
                                              child: RoundButton(
                                                  textFontSize: 16,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  title: "Agenda Meetings",
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                AgendaMeetingByCommittee(
                                                                    pkcode: commiteeListMeember[
                                                                            index]
                                                                        [
                                                                        'pkcode'])));
                                                  })),
                                          SizedBox(height: 20),
                                          Center(
                                              child: RoundButton(
                                            textFontSize: 16,
                                            title: "Minutes of Meetings",
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => MOMByCommittee(
                                                          pkcode:
                                                              commiteeListMeember[
                                                                      index]
                                                                  ['pkcode'])));
                                            },
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )),
                                          SizedBox(height: 20),
                                          Center(
                                              child: RoundButton(
                                                  textFontSize: 16,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  title: "Committee Members",
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                CommitteeDetailsScreen(
                                                                  name:
                                                                      '${commiteeListMeember[index]['name'].toString()}',
                                                                  tid: int.parse(
                                                                      "${commiteeListMeember[index]['pkcode']}"),
                                                                )));
                                                  })),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: item(index,
                                commiteeListMeember[index]['name'].toString()),
                          );
                        },
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }

  Widget item(int index, name) {
    return AnimatedContainer(
      height: 55,
      width: screenWidth,
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300 + (index * 200)),
      transform:
          Matrix4.translationValues(startAnimation ? 0 : screenWidth, 0, 0),
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth / 22,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              "${index + 1}. ${name}",
              style: TextStyle(
                // fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
