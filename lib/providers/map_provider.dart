import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class ProviderController extends ChangeNotifier {
  double? lat;
  double? long;
  List<Marker> hospitalMarkers = [];
  Map sliderData = {};

  bool checkLogin = false;
  String address = '';
  LocationPermission? locationPermission;
  bool result = false;
  Locale? lang = const Locale('ar');
  int? module;
  bool end = false;

  Future getDataLocation() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore.collection("posts").get();
    return qn.docs;
  }

  Future check() async {
    // return Geolocator.requestPermission();
    return Geolocator.checkPermission().then((value) {
      if (value == LocationPermission.denied) {
        return Geolocator.requestPermission();
      } else {
        return true;
      }
    });
    // notifyListeners();
  }

  Future<Position?> getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    lat = lastPosition!.latitude;
    long = lastPosition.longitude;
    print(lat);
    print(long);
    end = false;
    // notifyListeners();
    return lastPosition;
  }

  void change(lat1, long1) {
    lat = lat1;
    long = long1;
    notifyListeners();
  }
}
