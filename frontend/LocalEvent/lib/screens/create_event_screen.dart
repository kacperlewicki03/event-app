import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  LatLng? selectedLocation;
  String? selectedLocationName;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String selectedCategory = "Ogólne";
  
  final List<String> categories = [
    "Ogólne",
    "Edukacja",
    "Sport",
    "Integracja",
    "Inne",
  ];

  Future<String> getLocationName(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    final place = placemarks.first;

    return [
      place.street,
      place.subLocality,
      place.locality,
      place.country
    ].where((e) => e != null && e.isNotEmpty).join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Utwórz wydarzenie")),
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
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(labelText: "Kategoria"),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),


            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: const Text("Wybierz datę"),
            ),

            const SizedBox(height: 10),

            Text(
              selectedDate == null
                ? "Nie wybrano daty"
                : "Data: ${selectedDate!.toLocal().toString().split(' ')[0]}",
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: const Text("Wybierz godzinę"),
            ),

            const SizedBox(height: 10),

            Text(
              selectedTime == null
                ? "Nie wybrano godziny"
                : "Godzina: ${selectedTime!.format(context)}",
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final loc = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapPickerScreen(
                      onLocationSelected: (loc) {
                        Navigator.pop(context, loc);
                      },
                    ),
                  ),
                );
                if (loc != null) {
                  final name = await getLocationName(loc);
                  setState(() {
                    selectedLocation = loc;
                    selectedLocationName = name;
                  });
                }
              },
              child: const Text("Wybierz lokalizację na mapie"),
            ),

            const SizedBox(height: 20),

            Text(
              selectedLocationName ?? "Nie wybrano lokalizacji"
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                if (selectedLocation == null || selectedDate == null || selectedTime == null ) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Uzupełnij wszystkie dane!")),
                  );
                  return;
                }
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Podaj nazwę wydarzenia!")),
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

                final name = selectedLocationName ?? 
                  await getLocationName(selectedLocation!);

                await ApiService().createEvent({
                  "title": titleController.text,
                  "description": descriptionController.text,
                  "category": selectedCategory,
                  "date": dateTime.toIso8601String(),
                  "location": name,
                  "latitude": selectedLocation!.latitude,
                  "longitude": selectedLocation!.longitude,
                });

                Navigator.pop(context);
              },
              child: const Text("Zapisz wydarzenie"),
            ),
          ],
        ),
      ),
    );
  }
}