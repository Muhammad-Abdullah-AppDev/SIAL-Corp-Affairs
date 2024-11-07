import 'package:flutter/material.dart';
import 'package:sial_app/Pages/FlightSchedule/arrivals_screen.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class DepartureScreen extends StatefulWidget {
  DepartureScreen({Key? key}) : super(key: key);

  @override
  State<DepartureScreen> createState() => _DepartureScreenState();
}

class _DepartureScreenState extends State<DepartureScreen> {
  TextEditingController departureSearchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> flightDetails;
  bool isFocused = false;
  String searchField = ' Search by Flight No or Destination';
  String searchText = '';
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    // Fetch flight details when the widget is initialized
    flightDetails = fetchFlightDetails();
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchFlightDetails() async {
    final response = await http.get(Uri.parse(
        'https://erm.scarletsystems.com:1050/api/FlightBoard/GetAllDeparture'));

    if (response.statusCode == 200) {
      // Parse the response as a List<dynamic>
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load flight details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Departure:  Live Flight Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: flightDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While waiting for data, display a loading indicator
                return SpinKitFadingCube(
                  color: Theme.of(context).colorScheme.primary,
                  size: 50,
                  duration: Duration(milliseconds: 600),
                );
              } else if (snapshot.hasError) {
                // If there's an error, display an error message
                return Text('Error: ${snapshot.error}');
              } else {
                // If data is successfully loaded, build the UI with the fetched data
                final flightDataList = snapshot.data ?? [];
        
                return Container(
                  color: Color(0xff2d334d).withOpacity(0.6),
                  height: MediaQuery.of(context).size.height * 1,
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // RichText(
                        //   text: const TextSpan(
                        //     text: 'Live Flight ',
                        //     style: TextStyle(
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.w400,
                        //       color: Colors.white,
                        //     ),
                        //     children: [
                        //       TextSpan(
                        //         text: 'Details',
                        //         style: TextStyle(
                        //           fontSize: 23,
                        //           fontWeight: FontWeight.w500,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          padding: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      //Navigator.push(context, MaterialPageRoute(builder: (_)=>  DepartureScreen()));
                                      // Handle the second button press
                                    },
                                    icon: const ImageIcon(
                                      AssetImage(
                                        'assets/images/departure.png',
                                      ),
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Departure',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(160, 50),
                                      backgroundColor: Color(0xe7de1b1f),
                                      elevation: 8,
                                      // Set the background color
                                      shadowColor: Colors.black,
                                      // Set the shadow color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            25.0), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  // Add some spacing between the buttons
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => ArivalsScreen()));
                                        // Handle the second button press
                                      },
                                      icon: const ImageIcon(
                                        AssetImage(
                                          'assets/images/landing.png',
                                        ),
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Arrival',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(160, 50),
                                        backgroundColor: Color(0xff34394f),
                                        elevation: 8,
                                        // Set the background color
                                        shadowColor: Colors.black,
                                        // Set the shadow color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              25.0), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Material(
                                borderRadius: BorderRadius.circular(10.0),
                                color:
                                    isFocused ? Colors.white70 : Colors.white30,
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      isFocused = hasFocus;
                                    });
                                  },
                                  child: TextFormField(
                                    controller: departureSearchController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: isFocused
                                          ? ' Enter Destination or Flight No...'
                                          : searchField,
                                      filled: false,
                                    ),
                                    onChanged: (String? value) {
                                      debugPrint('Search Value : $value');
                                      setState(() {
                                        searchText = value.toString();
                                      });
                                    },
                                  ),
                                ),
                              ),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                    'Departure Schedule',
                                    speed: Duration(milliseconds: 150),
                                    textStyle: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'd',
                                    ),
                                  ),
                                ],
                                repeatForever: true,
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          indent: 50,
                          endIndent: 50,
                          thickness: 1,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 4.0), // Add some spacing
                        Expanded(
                          child: ListView.builder(
                            itemCount: flightDataList.length,
                            itemBuilder: (context, index) {
                              final flightData = flightDataList[index];
                              debugPrint(
                                  'Flight Departure List : ${flightDataList[index]}');
        
                              late String position1 =
                                  flightData['flnr'].toString();
                              debugPrint(
                                  'Flight data is: ${position1.toString()}');
        
                              late String position2 = flightData['citY_LNG1'];
                              debugPrint(
                                  'Flight data is: ${position2.toString()}');
        
                              currentDate = flightData['stD_DATE'];
        
                              if (departureSearchController.text.isEmpty) {
                                if (index == 0 ||
                                    currentDate !=
                                        flightDataList[index - 1]['stD_DATE']) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 15, bottom: 10),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.black54),
                                          child: Center(
                                            child: Text(
                                              '---  Date:  $currentDate  ---', // You may want to format the date as needed
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.9,
                                          // height:
                                          //     MediaQuery.of(context).size.height *
                                          //         0.24,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.blue.withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          child: buildFlightDetails(flightData),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    width:
                                        MediaQuery.of(context).size.width * 0.80,
                                    // height:
                                    //     MediaQuery.of(context).size.height * 0.24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    child: buildFlightDetails(flightData),
                                  );
                                }
                              } else if (position1
                                      .toString()
                                      .toLowerCase()
                                      .contains(departureSearchController.text
                                          .toLowerCase()) ||
                                  position2.toString().toLowerCase().contains(
                                      departureSearchController.text
                                          .toLowerCase())) {
                                if (index == 0 ||
                                    currentDate !=
                                        flightDataList[index - 1]['stD_DATE'] ||
                                    index != 0) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 15, bottom: 10),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: Colors.black54),
                                          child: Center(
                                            child: Text(
                                              '---  Date:  $currentDate  ---', // You may want to format the date as needed
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.yellow,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.9,
                                          // height:
                                          //     MediaQuery.of(context).size.height *
                                          //         0.24,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.blue.withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          child: buildFlightSearchDetails(
                                              flightData, position1, position2),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      width: MediaQuery.of(context).size.width *
                                          0.80,
                                      // height: MediaQuery.of(context).size.height *
                                      //     0.24,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      child: buildFlightSearchDetails(
                                          flightData, position1, position2));
                                }
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildFlightDetails(Map<String, dynamic> flightData) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AIRLINE ایئرلائن :',
                style: TextStyle(
                  fontFamily: 'Urdu',
                ),
              ),
              const SizedBox(width: 5),
              Text(
                flightData['car'] ?? 'N/A',
                style: const TextStyle(
                    fontFamily: 'Urdu', color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'To  منزل',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  flightData['citY_LNG1'].toString().toUpperCase() +
                          ('  ') +
                          flightData['citY_LNG2'] ??
                      'N/A',
                  style: const TextStyle(
                      fontFamily: 'Urdu', color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Flight No پرواز',
                  style: TextStyle(
                    fontFamily: 'Urdu',

                  ),
                ),
                Text(
                  flightData['flnr'] ?? 'N/A',
                  style: const TextStyle(
                      fontFamily: 'Urdu',

                      color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule وقت ',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  flightData['stD_TIME'] ?? 'N/A',
                  style: const TextStyle(
                      fontFamily: 'Urdu',
                      color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status کیفیت  ',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  flightData['reM_LNG1'] + ('   ') + flightData['atD_TIME'] ??
                      'N/A',
                  style: TextStyle(
                      fontFamily: 'Urdu',
                      color: flightData['reM_LNG1'] == 'Departed'
                          ? Colors.green
                          : Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlightSearchDetails(
      Map<String, dynamic> flightData, position1, position2) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AIRLINE ایئرلائن :',
                style: TextStyle(
                  fontFamily: 'Urdu',
                ),
              ),
              const SizedBox(width: 5),
              Text(
                flightData['car'] ?? 'N/A',
                style: const TextStyle(
                    fontFamily: 'Urdu', color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'To  منزل',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  position2.toString().toUpperCase() +
                      ('  ') +
                      flightData['citY_LNG2'],
                  style:
                      const TextStyle(fontFamily: 'Urdu', color: Colors.indigo),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Flight No پرواز',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  "${position1.toString()}",
                  style: const TextStyle(
                      fontFamily: 'Urdu', color: Colors.indigo),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule وقت ',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  flightData['stD_TIME'] ?? 'N/A',
                  style: const TextStyle(
                      fontFamily: 'Urdu',
                      color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          Divider(
            height: 4,
            thickness: 2,
            endIndent: 20,
            indent: 20,
            color: Colors.blueGrey.shade400,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status کیفیت  ',
                  style: TextStyle(
                    fontFamily: 'Urdu',
                  ),
                ),
                Text(
                  flightData['reM_LNG1'] + ('   ') + flightData['atD_TIME'] ??
                      'N/A',
                  style: TextStyle(
                      fontFamily: 'Urdu',
                      color: flightData['reM_LNG1'] == 'Departed'
                          ? Colors.green
                          : Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}