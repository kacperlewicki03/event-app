import 'package:flutter/material.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String location;
  final double latitude;
  final double longitude;
  final int? userId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      date: json['date'],
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      userId: json['user_id'] == null ? null : json['user_id'] as int,
    );
  }
}
