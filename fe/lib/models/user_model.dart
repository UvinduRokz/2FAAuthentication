class User {
  final int id;
  final String username;
  final String email;
  final bool twoFaEnabled;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.twoFaEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      twoFaEnabled:
          json['twoFaEnabled'] == null ? false : json['twoFaEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'twoFaEnabled': twoFaEnabled,
      };

  User copyWith(
      {int? id, String? username, String? email, bool? twoFaEnabled}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
    );
  }
}
