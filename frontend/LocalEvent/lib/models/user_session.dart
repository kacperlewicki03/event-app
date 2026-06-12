class UserSession {
  final int id;
  final String username;
  final String email;
  final String token;

  UserSession({
    required this.id,
    required this.username,
    required this.email,
    required this.token,
  });

  factory UserSession.fromApi(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return UserSession(
      id: user['id'] as int,
      username: user['username'].toString(),
      email: user['email'].toString(),
      token: json['token'].toString(),
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as int,
      username: json['username'].toString(),
      email: json['email'].toString(),
      token: json['token'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "token": token,
    };
  }
}