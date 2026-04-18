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
}
