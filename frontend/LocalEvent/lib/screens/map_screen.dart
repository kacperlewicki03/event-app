import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import '../utils/category_colors.dart';

class MapScreen extends StatefulWidget {
  final void Function(LatLng)? onLocationSelected;
  const MapScreen({super.key, this.onLocationSelected});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Event> events = [];
  Set<Marker> markers = {};

  Event? selectedEvent;

  static const LatLng _centerOfPoland = LatLng(52.0688, 19.4797);
  LatLng? selectedLocation;

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> loadEvents() async {
    final data = await ApiService().fetchEvents();

    setState(() {
      events = data;
      markers = data.map((event) {
        return Marker(
          markerId: MarkerId(event.title),
          position: LatLng(event.latitude, event.longitude),
          icon: getMarkerColor(event.category),
          infoWindow: InfoWindow(
            title: event.title,
            snippet: event.location,
          ),
          onTap: () {
            setState(() {
              selectedEvent = event;
            });
          }
        );
      }).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _centerOfPoland,
              zoom: 6.0,
            ),
            markers: markers,
            onTap: (LatLng position) {
              setState(() {
                selectedEvent = null;
              });
            },
          ),

          if (selectedEvent != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedEvent!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18),
                        const SizedBox(width: 5),
                        Expanded(child: Text(selectedEvent!.location)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getCategoryColor(selectedEvent!.category).withValues(alpha: 0.85),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(event: selectedEvent!),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              selectedEvent = null;
                            });
                            await loadEvents();
                          }
                        },
                        child: const Text("Zobacz szczegóły"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
