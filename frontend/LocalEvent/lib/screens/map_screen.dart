import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';
import '../utils/colors/app_colors.dart';
import '../utils/colors/category_colors.dart';

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

  static const LatLng _wroclawCenter = LatLng(51.1079, 17.0385);
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
            onTap: () {
              setState(() {
                selectedEvent = event;
              });
            });
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
              target: _wroclawCenter,
              zoom: 13.0,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            selectedEvent!.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              selectedEvent = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tytuł wydarzenia
                    Text(
                      selectedEvent!.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedEvent!.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              getCategoryColor(selectedEvent!.category),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EventDetailScreen(event: selectedEvent!),
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
