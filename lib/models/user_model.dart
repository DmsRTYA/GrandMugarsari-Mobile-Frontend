// lib/models/user_model.dart

import 'app_constants.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role; // 'admin' | 'staff' (ditampilkan sebagai 'Pelanggan')

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.role = kRoleStaff,
  });

  bool get isAdmin => role == kRoleAdmin;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? kRoleStaff,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'username': username, 'email': email, 'role': role};

  User copyWith({String? role}) => User(
        id: id,
        username: username,
        email: email,
        role: role ?? this.role,
      );
}
