import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_picker_screen.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import '../utils/colors/app_colors.dart';

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
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      ).timeout(const Duration(seconds: 8));

      if (placemarks.isEmpty) {
        return _coordinatesFallback(latLng);
      }

      final place = placemarks.first;
      final addressParts = [
        place.street,
        place.subLocality,
        place.locality,
      ]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .toList();

      if (addressParts.isEmpty) {
        return _coordinatesFallback(latLng);
      }

      return addressParts.join(", ");
    } on TimeoutException {
      return _coordinatesFallback(latLng);
    } catch (e) {
      debugPrint("Błąd pobierania adresu: $e");
      return _coordinatesFallback(latLng);
    }
  }

  String _coordinatesFallback(LatLng latLng) {
    return "Wybrany punkt: "
        "${latLng.latitude.toStringAsFixed(5)}, "
        "${latLng.longitude.toStringAsFixed(5)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Utwórz wydarzenie"),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Nazwa wydarzenia",
                  hintText: "Np. Spotkanie integracyjne",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Opis",
                  hintText: "Dodaj szczegóły wydarzenia...",
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Kategoria"),
                dropdownColor: AppColors.surface,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                "Szczegóły",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary.withOpacity(0.8)),
              ),
              const SizedBox(height: 12),
              _buildSelectorCard(
                icon: Icons.calendar_today_rounded,
                title: selectedDate == null
                    ? "Wybierz datę"
                    : "Data: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                isSelected: selectedDate != null,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildSelectorCard(
                icon: Icons.access_time_rounded,
                title: selectedTime == null
                    ? "Wybierz godzinę"
                    : "Godzina: ${selectedTime!.format(context)}",
                isSelected: selectedTime != null,
                onTap: () async {
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
              ),
              const SizedBox(height: 12),
              _buildSelectorCard(
                icon: Icons.map_rounded,
                title: selectedLocationName ?? "Wybierz lokalizację na mapie",
                isSelected: selectedLocation != null,
                onTap: () async {
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
                    setState(() =>
                        selectedLocationName = "Pobieranie lokalizacji...");
                    final name = await getLocationName(loc);
                    setState(() {
                      selectedLocation = loc;
                      selectedLocationName = name;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (selectedLocation == null ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Uzupełnij wszystkie dane!"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  if (titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Podaj nazwę wydarzenia!"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final formattedDate =
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                  final formattedTime = selectedTime!.format(context);
                  final name = selectedLocationName ??
                      await getLocationName(selectedLocation!);

                  try {
                    await ApiService().createEvent({
                      "title": titleController.text.trim(),
                      "description": descriptionController.text.trim(),
                      "category": selectedCategory,
                      "date": formattedDate,
                      "time": formattedTime,
                      "location": name,
                      "latitude": selectedLocation!.latitude,
                      "longitude": selectedLocation!.longitude,
                      "image_url": "",
                      "status": "UPCOMING"
                    });

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Błąd serwera: $e"),
                            backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                child: const Text("Zapisz wydarzenie"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.15),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.4),
        ),
      ),
    );
  }
}
