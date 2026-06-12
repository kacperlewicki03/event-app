import 'package:event_app/screens/map_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../models/event.dart';
import '../services/api_service.dart';
import '../utils/colors/app_colors.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  final bool ownedMode;

  const EditEventScreen({
    super.key,
    required this.event,
    this.ownedMode = false,
  });

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

    try {
      selectedTime = TimeOfDay.fromDateTime(
        DateTime.parse(widget.event.date),
      );
    } catch (_) {
      selectedTime = TimeOfDay.now();
    }
  }

  Future<String> getLocationName(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      final place = placemarks.first;
      return [place.street, place.subLocality, place.locality]
          .where((e) => e != null && e.isNotEmpty)
          .join(", ");
    } catch (e) {
      return "Wybrany punkt na mapie";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edytuj wydarzenie"),
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
                  hintText: "Zmień nazwę wydarzenia...",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Opis",
                  hintText: "Zmień opis lub agendę...",
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Kategoria"),
                dropdownColor: AppColors.surface,
                items: categories.map((c) {
                  return DropdownMenuItem(
                      value: c,
                      child: Text(c,
                          style:
                              const TextStyle(color: AppColors.textPrimary)));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                "Modyfikuj szczegóły",
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
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
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
              ),
              const SizedBox(height: 12),
              _buildSelectorCard(
                icon: Icons.map_rounded,
                title: selectedLocationName ?? "Wybierz lokalizację na mapie",
                isSelected: selectedLocation != null,
                onTap: () async {
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
                    setState(
                        () => selectedLocationName = "Aktualizacja adresu...");
                    final name = await getLocationName(result);
                    setState(() {
                      selectedLocation = result;
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
                      selectedTime == null ||
                      titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Uzupełnij wszystkie dane przed zapisem!"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final formattedDate =
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                  final formattedTime = selectedTime!.format(context);

                  try {
                    final eventData = {
                        "title": titleController.text.trim(),
                        "description": descriptionController.text.trim(),
                        "category": selectedCategory,
                        "date": formattedDate,
                        "time": formattedTime,
                        "location": selectedLocationName,
                        "latitude": selectedLocation!.latitude,
                        "longitude": selectedLocation!.longitude,
                        "image_url": "",
                        "status": "UPCOMING"
                        };

                    if (widget.ownedMode) {
                      await ApiService().updateMyEvent(widget.event.id, eventData);
                    } else {
                      await ApiService().updateEvent(widget.event.id, eventData);
                    }

                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Błąd aktualizacji: $e"),
                            backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
                child: const Text("Zapisz zmiany"),
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
