import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/user_session.dart';
import 'auth_storage.dart';

class ApiService {
  // UWAGA: Jeśli testujesz na emulatorze Androida, zamiast localhost wpisz 10.0.2.2
  // Jeśli na iPhone/Web - localhost jest OK.
  static const String baseUrl = "http://10.0.2.2:8000";

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Event.fromJson(item)).toList();
    } else {
      throw Exception("Nie udało się pobrać wydarzeń");
    }
  }

  Future<void> createEvent(Map<String, dynamic> event) async {
  final session = await AuthStorage().readSession();

  final url = session == null
      ? '$baseUrl/events'
      : '$baseUrl/my-events';

  final headers = session == null
      ? {"Content-Type": "application/json"}
      : {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${session.token}",
        };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(event),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(_errorMessage(response));
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



  String _errorMessage(http.Response response) {
  try {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
      return decoded['detail'].toString();
    }
  } catch (_) {}

  return "Wystąpił błąd połączenia z serwerem";
}

Future<Map<String, String>> _authHeaders() async {
  final session = await AuthStorage().readSession();

  if (session == null) {
    throw Exception("Brak aktywnej sesji użytkownika");
  }

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer ${session.token}",
  };
}

Future<UserSession> loginUser({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return UserSession.fromApi(jsonDecode(response.body));
  }

  throw Exception(_errorMessage(response));
}

Future<UserSession> registerUser({
  required String username,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": username,
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return UserSession.fromApi(jsonDecode(response.body));
  }

  throw Exception(_errorMessage(response));
}

Future<List<Event>> fetchMyEvents() async {
  final response = await http.get(
    Uri.parse('$baseUrl/my-events'),
    headers: await _authHeaders(),
  );

  if (response.statusCode == 200) {
    final List<dynamic> body = jsonDecode(response.body);
    return body.map((item) => Event.fromJson(item)).toList();
  }

  throw Exception(_errorMessage(response));
}

Future<void> updateMyEvent(int id, Map<String, dynamic> event) async {
  final response = await http.put(
    Uri.parse('$baseUrl/my-events/$id'),
    headers: await _authHeaders(),
    body: jsonEncode(event),
  );

  if (response.statusCode != 200) {
    throw Exception(_errorMessage(response));
  }
}

Future<void> deleteMyEvent(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/my-events/$id'),
    headers: await _authHeaders(),
  );

  if (response.statusCode != 200) {
    throw Exception(_errorMessage(response));
  }
}












}
