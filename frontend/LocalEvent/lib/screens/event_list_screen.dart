import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = ApiService().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Błąd: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Brak wydarzeń"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final event = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text("${event.date} - ${event.location}"),
              ),
            );
          },
        );
      },
    );
  }
}
