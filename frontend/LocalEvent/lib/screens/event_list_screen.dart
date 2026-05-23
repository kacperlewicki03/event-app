import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';
import '../utils/colors/app_colors.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> futureEvents;

  List<Event> allEvents = [];
  List<Event> filteredEvents = [];

  final searchController = TextEditingController();
  String selectedCategoryFilter = "Wszystkie";

  final List<String> categoryFilters = [
    "Wszystkie",
    "Ogólne",
    "Edukacja",
    "Sport",
    "Integracja",
    "Inne",
  ];

  @override
  void initState() {
    super.initState();
    futureEvents = ApiService().fetchEvents();
  }

  void filterEvents() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredEvents = allEvents.where((event) {
        final matchesSearch = event.title.toLowerCase().contains(query);

        final matchesCategory = selectedCategoryFilter == "Wszystkie"
            ? true
            : event.category.toLowerCase() ==
                selectedCategoryFilter.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void refreshEvents() {
    setState(() {
      futureEvents = ApiService().fetchEvents();
      searchController.clear();
      selectedCategoryFilter = "Wszystkie";
      filteredEvents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Event>>(
          future: futureEvents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Błąd połączenia z API: ${snapshot.error}",
                    style: const TextStyle(color: AppColors.error)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Brak nadchodzących wydarzeń",
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16)),
              );
            }

            allEvents = snapshot.data!;

            if (filteredEvents.isEmpty &&
                searchController.text.isEmpty &&
                selectedCategoryFilter == "Wszystkie") {
              filteredEvents = allEvents;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 24, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cześć student!",
                        style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Przeglądaj Wydarzenia",
                        style: TextStyle(
                            fontSize: 28,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => filterEvents(),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: "Wyszukaj interesujące Cię wydarzenie...",
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.primaryLight),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: categoryFilters.map((category) {
                      final isSelected = selectedCategoryFilter == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryFilter = category;
                            });
                            filterEvents();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredEvents.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];

                      String formattedDate;
                      try {
                        DateTime parsedDate = DateTime.parse(event.date);
                        formattedDate =
                            DateFormat('EEE, d MMM yyyy • HH:mm', 'pl_PL')
                                .format(parsedDate);
                      } catch (_) {
                        formattedDate = event.date;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailScreen(event: event),
                                  ),
                                );
                                if (result == true) {
                                  refreshEvents();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            event.category.toUpperCase(),
                                            style: const TextStyle(
                                              color: AppColors.primaryLight,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 16,
                                            color: AppColors.primaryLight),
                                        const SizedBox(width: 6),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded,
                                            size: 16, color: AppColors.error),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            event.location,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
          refreshEvents();
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
