import 'package:flutter/material.dart';

class Event {
  final String title;
  final String category;
  final String date;
  final String location;
  final IconData icon;

  Event({
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.icon,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      category: json['category'],
      date: json['date'],
      location: json['location'],
      icon: Icons.event,
    );
  }
}
