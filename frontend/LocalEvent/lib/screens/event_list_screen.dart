import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'create_event_screen.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';
import '../utils/category_colors.dart';

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

  void filterEvents(String query) {
    setState(() {
      filteredEvents = allEvents.where((event) {
        final matchesSearch = event.title
          .toLowerCase()
          .contains(query.toLowerCase());

        final matchesCategory =
          selectedCategoryFilter == "Wszystkie"
            ? true
            : event.category == selectedCategoryFilter;

        return matchesSearch && matchesCategory;
        
      }).toList();
    });
  }

  void refreshEvents() {
    setState(() {
      futureEvents = ApiService().fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Event>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Brak wydarzeń"));
          }

          allEvents = snapshot.data!;

          if (filteredEvents.isEmpty && searchController.text.isEmpty) {
            filteredEvents = allEvents;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  onChanged: filterEvents,
                  decoration: InputDecoration(
                    hintText: "Wyszukaj wydarzenie..",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCategoryFilter,

                  decoration: InputDecoration(
                    labelText: "Filtr kategorii",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  items: categoryFilters.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategoryFilter = value!;
                    });

                    filterEvents(searchController.text);
                  },
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {

                    final event = filteredEvents[index];
                    final color = getCategoryColor(event.category);

                    return Card(
                      margin: const EdgeInsets.all(8),
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: color,
                              width: 6,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Text("${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(event.date))} - ${event.location}"),

                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EventDetailScreen(event: event),),
                            );
                            if (result == true) {
                              refreshEvents();
                            }
                          },
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

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
          refreshEvents();
        },
      ),
    );
  }
}
