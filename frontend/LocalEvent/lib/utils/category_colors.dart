import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Color getCategoryColor(String category) {
  switch (category) {
    case "Ogólne":
      return Color.fromARGB(255, 209, 128, 6);
    case "Edukacja":
      return Color.fromARGB(255, 19, 210, 25);
    case "Sport":
      return Color.fromARGB(255, 30, 40, 238);
    case "Integracja":
      return Color.fromARGB(255, 101, 22, 181);
    case "Inne":
      return Color.fromARGB(255, 227, 43, 105);
    default:
      return Color.fromARGB(255, 83, 83, 83);
  }
}

BitmapDescriptor getMarkerColor(String category) {
  switch (category) {
    case "Ogólne":
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    case "Edukacja":
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    case "Sport":
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    case "Integracja":
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    case "Inne":
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    default:
      return BitmapDescriptor.defaultMarker;
  }
}