import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  // UWAGA: Jeśli testujesz na emulatorze Androida, zamiast localhost wpisz 10.0.2.2
  // Jeśli na iPhone/Web - localhost jest OK.
  static const String baseUrl = "http://10.0.2.2:8000";

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      // Mapujemy listę JSON na listę obiektów klasy Event
      return body.map((dynamic item) => Event.fromJson(item)).toList();
    } else {
      throw Exception("Nie udało się pobrać wydarzeń");
    }
  }

  Future<void> createEvent(Map<String, dynamic> event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(event),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Nie udało się dodać wydarzenia");
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception("Nie udało się usunąć wydarzenia");
    }
  }

  Future<void> updateEvent(int id, Map<String, dynamic> event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(event),
    );

    if (response.statusCode != 200) {
      throw Exception("Nie udało się zaktualizować wydarzenia");
    }
  }
}
