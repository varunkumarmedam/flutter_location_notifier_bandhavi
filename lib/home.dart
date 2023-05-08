import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final Completer<GoogleMapController> _controller = Completer();

  late Position currentLocation;

  Future getCurrentLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return currentLocation;
  }

  Future getTodos() async {
    await getCurrentLocation();
    var box = await Hive.openBox('todos');
    var todos = box.get('todos');
    if (todos != null) {
      todos = json.decode(todos);
    } else {
      todos = [];
    }
    return todos;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Available Tasks"),
          bottom: TabBar(tabs: [
            Tab(icon: Icon(Icons.task_alt_rounded), text: "Available Tasks"),
            Tab(icon: Icon(Icons.done_outline_rounded), text: "Completed")
          ]),
        ),
        body: TabBarView(
          children: [
            FutureBuilder(
              future: getTodos(),
              builder: (ctx, snapshot) {
                // Checking if future is resolved or not
                if (snapshot.connectionState == ConnectionState.done) {
                  // If we got an error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error} occurred',
                        style: TextStyle(fontSize: 18),
                      ),
                    );

                    // if we got our data
                  } else if (snapshot.hasData) {
                    // Extracting data from snapshot object
                    final data = snapshot.data;
                    return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Color.fromARGB(255, 223, 240, 255)
                                    : Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((index + 1).toString()),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: ListTile(
                                            title: Text(
                                          "${data[index]['name']}",
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  (Geolocator.distanceBetween(
                                                  currentLocation.latitude,
                                                  currentLocation.longitude,
                                                  data[index]['lat'],
                                                  data[index]['lng']) *
                                              0.000621371192)
                                          .toStringAsFixed(2) +
                                      ' miles',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        });
                  }
                }

                // Displaying LoadingSpinner to indicate waiting state
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Text("data")
          ],
        ),
      ),
    );
  }
}
