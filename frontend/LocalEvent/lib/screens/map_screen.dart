import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Współrzędne geograficzne środka Polski
  static const LatLng _centerOfPoland = LatLng(52.0688, 19.4797);

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _centerOfPoland,
          zoom: 6.0, // Przybliżenie pozwalające widzieć całą Polskę
        ),
        // Tu w przyszłości dodamy markery z wydarzeniami z Pythona
        markers: {
          const Marker(
            markerId: MarkerId('poland_center'),
            position: _centerOfPoland,
            infoWindow: InfoWindow(title: 'Środek Polski'),
          ),
        },
      ),
    );
  }
}
