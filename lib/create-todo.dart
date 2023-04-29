import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:google_maps_place_picker_mb/providers/place_provider.dart';
import 'package:google_maps_place_picker_mb/providers/search_provider.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateTodo extends StatefulWidget {
  const CreateTodo({super.key});
  // static final kInitialPosition = latLng.LatLng(-33.8567844, 151.213108);

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  late bool permissionGranted;
  PickResult? selectedPlace;
  bool _showPlacePickerInContainer = true;

  final todoDescriptionCtrl = TextEditingController();
  final todoRadiusCtrl = TextEditingController();

  Future _getLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.location.request().isPermanentlyDenied) {
      throw ('location.request().isPermanentlyDenied');
    } else if (await Permission.location.request().isDenied) {
      throw ('location.request().isDenied');
      permissionGranted = false;
    }
  }

  void saveTodo() async {
    var box = await Hive.openBox('todos');
    // box.clear();
    var todos = box.get('todos');

    if (todos != null) {
      todos = json.decode(todos);
    } else {
      todos = [];
    }
    Map currentTodo = {
      "name": selectedPlace!.name.toString(),
      "description": todoDescriptionCtrl.text,
      "radius": int.parse(todoRadiusCtrl.text),
      "address": selectedPlace!.formattedAddress.toString(),
      "lat": selectedPlace!.geometry!.location.lat,
      "lng": selectedPlace!.geometry!.location.lng,
      "created_on": DateTime.now().toString()
    };
    print(todos);
    todos.add(currentTodo);
    await box.put("todos", json.encode(todos));
    Navigator.pop(context);
  }

  @override
  void initState() {
    _getLocationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 15),
                height: 100,
                decoration: BoxDecoration(color: Colors.purple),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: Text(
                        "Create a Todo",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 80),
                  padding: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: _showPlacePickerInContainer
                      ? PlacePicker(
                          automaticallyImplyAppBarLeading: false,
                          forceAndroidLocationManager: true,
                          apiKey: "AIzaSyDXUi5en6uoWnnNmuG1ttoMCRIJfghjzxw",
                          hintText: "Find a place ...",
                          searchingText: "Please wait ...",
                          selectText: "Select place",
                          initialPosition: LatLng(-33.8567844, 151.213108),
                          useCurrentLocation: true,
                          selectInitialPosition: true,
                          usePinPointingSearch: false,
                          usePlaceDetailSearch: true,
                          zoomGesturesEnabled: false,
                          zoomControlsEnabled: false,
                          enableMapTypeButton: false,
                          enableMyLocationButton: false,
                          onPlacePicked: (PickResult result) {
                            setState(() {
                              selectedPlace = result;
                              _showPlacePickerInContainer = false;
                            });
                          },
                          onTapBack: null)
                      : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple,
                                    blurRadius: 10,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.purple, width: 0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Selected location"),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        selectedPlace!.formattedAddress!,
                                        style: TextStyle(fontSize: 30),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Flexible(
                                    //   child: Text(
                                    //     "asdjha skdjashdlkah aksdhaksjdhba skjdhask jdnhaksdj haskd jnhadfd nakjfnah",
                                    //     style: TextStyle(fontSize: 30),
                                    //     overflow: TextOverflow.ellipsis,
                                    //   ),
                                    // ),
                                    // IconButton(
                                    //     onPressed: () => {
                                    //           setState(() {
                                    //             selectedPlace = null;
                                    //             _showPlacePickerInContainer =
                                    //                 true;
                                    //           })
                                    //         },
                                    //     icon: Icon(Icons.remove_circle_outline))
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text("Longitude - " +
                                    selectedPlace!.geometry!.location.lat
                                        .toString()),
                                Text("Latitude - " +
                                    selectedPlace!.geometry!.location.lng
                                        .toString()),
                                SizedBox(
                                  height: 20,
                                ),
                                OutlinedButton(
                                    onPressed: () => {
                                          setState(() {
                                            selectedPlace = null;
                                            _showPlacePickerInContainer = true;
                                          })
                                        },
                                    style: ButtonStyle(
                                        shadowColor: MaterialStatePropertyAll(
                                            Colors.purple)),
                                    child: SizedBox(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(Icons.delete_sweep_outlined),
                                          Text(
                                            "Reselect",
                                            style: TextStyle(
                                                color: Colors.purpleAccent),
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        )),
            ],
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width, // <-- TextField width
            height: 120, // <-- TextField height
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: TextField(
              maxLines: null,
              expands: true,
              controller: todoDescriptionCtrl,
              decoration: const InputDecoration(
                hintText: "Enter what you want to do when you reach here",
                // border: InputBorder.none,
                filled: true,
                fillColor: Color.fromARGB(255, 251, 227, 255),
                // enabledBorder: UnderlineInputBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(20)),
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: todoRadiusCtrl,
              decoration: const InputDecoration(
                hintText: "Please enter active radius in KMs",
                // border: InputBorder.none,
                filled: true,
                fillColor: Color.fromARGB(255, 251, 227, 255),
                // enabledBorder: UnderlineInputBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(10)),
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
              margin: EdgeInsets.only(left: 50, right: 50),
              child: (selectedPlace != null &&
                      todoDescriptionCtrl.text != '' &&
                      todoRadiusCtrl.text != '')
                  ? FilledButton(
                      onPressed: () => {saveTodo()},
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.purple)),
                      child: Text("Save"))
                  : OutlinedButton(
                      onPressed: () => {},
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.grey.shade300)),
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      )))
        ],
      ),
    );
  }
}
