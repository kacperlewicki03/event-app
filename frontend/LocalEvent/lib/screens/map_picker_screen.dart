import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  final void Function(LatLng) onLocationSelected;

  const MapPickerScreen({super.key, required this.onLocationSelected});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const LatLng _centerOfPoland = LatLng(52.0688, 19.4797);

  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wybierz lokalizację")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _centerOfPoland,
          zoom: 6,
        ),
        markers: {
          if (selectedLocation != null)
            Marker(
              markerId: const MarkerId('selected'),
              position: selectedLocation!,
            ),
        },
        onTap: (position) {
          setState(() {
            selectedLocation = position;
          });
        },
      ),
      floatingActionButton: selectedLocation != null
          ? FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () {
                widget.onLocationSelected(selectedLocation!);
              },
            )
          : null,
    );
  }
}