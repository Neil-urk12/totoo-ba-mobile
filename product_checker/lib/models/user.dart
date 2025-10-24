class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
