import 'package:flutter/material.dart';
import '../models/event_model.dart'; // Importujemy model z folderu obok

class EventListScreen extends StatelessWidget {
  EventListScreen({super.key});

  final List<Event> dummyEvents = [
    Event(
      title: 'Warsztaty z Fluttera',
      category: 'Edukacja',
      date: '12 Maj 2026, 17:00',
      location: 'Sala 101',
      icon: Icons.code,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: dummyEvents.length,
      itemBuilder: (context, index) {
        final event = dummyEvents[index];
        return Card(
          child: ListTile(
            leading: Icon(event.icon),
            title: Text(event.title),
            subtitle: Text('${event.date}\n${event.location}'),
          ),
        );
      },
    );
  }
}
