import 'package:event_app/screens/map_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../models/event.dart';
import '../services/api_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  LatLng? selectedLocation;
  String? selectedLocationName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late String selectedCategory;

  final List<String> categories = [
    "Ogólne",
    "Edukacja",
    "Sport",
    "Integracja",
    "Inne",
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.event.title);
    descriptionController =
        TextEditingController(text: widget.event.description);

    selectedCategory = widget.event.category;

    selectedLocation = LatLng(widget.event.latitude, widget.event.longitude);
    selectedLocationName = widget.event.location;

    selectedDate = DateTime.tryParse(widget.event.date);

    selectedTime = TimeOfDay.fromDateTime(
      DateTime.parse(widget.event.date),
    );
  }

  Future<String> getLocationName(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = placemarks.first;

    return [place.street, place.subLocality, place.locality, place.country]
        .where((e) => e != null && e.isNotEmpty)
        .join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj wydarzenie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Nazwa wydarzenia"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Opis"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Kategoria"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: const Text("Zmień datę"),
            ),
            const SizedBox(height: 10),
            Text(
              selectedDate == null
                  ? "Brak daty"
                  : "Data: ${selectedDate.toString().split(" ")[0]}",
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: const Text("Zmień godzinę"),
            ),
            const SizedBox(height: 10),
            Text(
              selectedTime == null
                  ? "Brak godziny"
                  : "Godzina: ${selectedTime!.format(context)}",
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapPickerScreen(
                      onLocationSelected: (position) {
                        Navigator.pop(context, position);
                      },
                    ),
                  ),
                );
                if (result != null) {
                  final name = await getLocationName(result);
                  setState(() {
                    selectedLocation = result;
                    selectedLocationName = name;
                  });
                }
              },
              child: const Text("Zmień lokalizację"),
            ),
            const SizedBox(height: 10),
            Text(selectedLocationName ?? ""),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (selectedLocation == null ||
                    selectedDate == null ||
                    selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Uzupełnij wszystkie dane")),
                  );
                  return;
                }

                final dateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                await ApiService().updateEvent(widget.event.id, {
                  "title": titleController.text,
                  "description": descriptionController.text,
                  "category": selectedCategory,
                  "date": dateTime.toIso8601String(),
                  "location": selectedLocationName,
                  "latitude": selectedLocation!.latitude,
                  "longitude": selectedLocation!.longitude,
                });

                Navigator.pop(context, true);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}
