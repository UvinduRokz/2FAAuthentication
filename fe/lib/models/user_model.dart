class User {
  final int id;
  final String username;
  final String email;
  final bool twoFaEnabled;
  final bool twoFaExpired; // 👈 new
  final DateTime? twoFaLastVerified; // 👈 new (optional)

  User({
    required this.id,
    required this.username,
    required this.email,
    this.twoFaEnabled = false,
    this.twoFaExpired = false,
    this.twoFaLastVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      twoFaEnabled: json['twoFaEnabled'] ?? false,
      twoFaExpired: json['twoFaExpired'] ?? false,
      twoFaLastVerified: json['twoFaLastVerified'] != null
          ? DateTime.tryParse(json['twoFaLastVerified'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'twoFaEnabled': twoFaEnabled,
        'twoFaExpired': twoFaExpired,
        'twoFaLastVerified': twoFaLastVerified?.toIso8601String(),
      };

  User copyWith({
    int? id,
    String? username,
    String? email,
    bool? twoFaEnabled,
    bool? twoFaExpired,
    DateTime? twoFaLastVerified,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      twoFaExpired: twoFaExpired ?? this.twoFaExpired,
      twoFaLastVerified: twoFaLastVerified ?? this.twoFaLastVerified,
    );
  }
}
