import 'package:event_app/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';
import '../utils/category_colors.dart';
import 'edit_event_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final categoryColor = getCategoryColor(event.category);
    final formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(event.date));

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Text(formattedDate),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 10),
                        Expanded(child: Text(event.location)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(event.latitude, event.longitude),
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(event.title),
                              position: LatLng(event.latitude, event.longitude),
                            ),
                          },
                          zoomControlsEnabled: false,
                          liteModeEnabled: true,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.category),
                        const SizedBox(width: 10),
                        Text(event.category),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Opis",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(event.description),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 107, 105, 125),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEventScreen(event: event),
                    ),
                  );

                  if (result == true) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Edytuj wydarzenie"),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 50, 49, 60),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {            
                  await ApiService().deleteEvent(event.id);
                  Navigator.pop(context, true);
                },
                child: const Text("Usuń wydarzenie"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}