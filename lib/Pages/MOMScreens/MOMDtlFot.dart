import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class MOMDtlFotScreen extends StatefulWidget {
  const MOMDtlFotScreen({super.key, required this.tid, required this.RtrNo});
  final int? tid;
  final int? RtrNo;
  @override
  State<MOMDtlFotScreen> createState() =>
      _MintuesOfMeetingDetails(tid: this.tid!, RtrNo: this.RtrNo!);
}

class _MintuesOfMeetingDetails extends State<MOMDtlFotScreen> {
  int tid;
  int RtrNo;
  _MintuesOfMeetingDetails({required this.tid, required this.RtrNo});
  @override
  List Agendadtl = [];
  bool isLoading = false;

  void initState() {
    super.initState();
    this.fetchMOMDtlFotDetails();
  }

  fetchMOMDtlFotDetails() async {
    // print("fetching...");
    isLoading = true;

    var request = await http.Request(
        'GET',
        Uri.parse(
            'https://erm.scarletsystems.com:1050/Api/MOMDtlFot/GetById?tid=$tid&Rtrno=$RtrNo'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var items = json.decode(await response.stream.bytesToString());
      debugPrint('hit MOMDtlFot 2 details api');
      setState(() {
        isLoading = false;

        Agendadtl = items;
        debugPrint('This is Agenda List: $Agendadtl');
      });
    } else {
      setState(() {
        isLoading = false;

        debugPrint('This is Agenda List: $Agendadtl');
        Agendadtl = [];

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
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            )))
          : Column(
              children: [
                Container(
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          // color: Color.fromARGB(255, 151, 151, 156),
                          borderRadius: BorderRadius.only(
                              // topLeft: Radius.circular(30),
                              // topRight: Radius.circular(30),
                              )),
                      child: Column(
                        children: [
                          Container(
                            height: 20.h,
                            width: double.infinity,
                            child: Image.asset("assets/images/agenda.jpg",
                                fit: BoxFit.cover),
                          ),
                          SizedBox(height: 1.h),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Theme.of(context).colorScheme.primary,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  " DETAILS",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Expanded(
                              child: Agendadtl.isEmpty
                                  ? Center(
                                      child: Text("No Data Found"),
                                    )
                                  : getList()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      // drawer: MyDrawer(),
    );
  }

  Widget getList() {
    // print("xxx${Agendadtl.length}");
    return ListView.builder(
      itemCount: Agendadtl.length,
      itemBuilder: (context, index) {
        //print('This is Agenda Detail: ${Agendadtl[index]}');
        return getCard(Agendadtl[index]);
      },
    );
  }

  Widget getCard(index) {
    var n = index["adtl"];
    var trno = index["trno"];
    String? rmks = index["rmks"] ?? '';
    String? rcmnd = index["rcmnd"] ?? '';
    String? asgnto = index["asgtno"] ?? '';

    return Card(
      color: Color.fromRGBO(217, 218, 253, 1),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.4.h),
        child: ListTile(
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: Text("Discussion :  ",
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary),),),
                  Expanded(
                    flex: 3,
                    child: HtmlWidget("$rmks",
                      textStyle: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).colorScheme.onTertiary),),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: Text("Recommendation : ",
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary),),),
                  Expanded(
                    flex: 2,
                    child: HtmlWidget("$rcmnd",
                      textStyle: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).colorScheme.onTertiary),),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text("Action :  ",
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiary),),),
                  Expanded(
                    flex: 3,
                    child: HtmlWidget("$asgnto",
                      textStyle: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).colorScheme.onTertiary),),
                  )
                ],
              ),
            ],
          ),
          // title: Text(
          //   n.toString(),
          //   style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 11.sp,
          //       color: Theme.of(context).colorScheme.onTertiary),
          // ),
          // trailing: Text(
          //   trno.toString(),
          //   style: TextStyle(
          //       fontSize: 10.sp,
          //       color: Theme.of(context).colorScheme.onTertiary),
          // ),
        ),
      ),
    );
  }
}
