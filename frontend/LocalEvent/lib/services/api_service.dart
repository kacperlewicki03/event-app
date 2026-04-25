import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  // UWAGA: Jeśli testujesz na emulatorze Androida, zamiast localhost wpisz 10.0.2.2
  // Jeśli na iPhone/Web - localhost jest OK.
  static const String baseUrl = "http://localhost:8000";

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
}
