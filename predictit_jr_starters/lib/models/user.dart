/// Mock user account. Plaintext password is for teaching only — see README.
class User {
  const User({
    required this.username,
    required this.password,
    required this.displayName,
    required this.startingBalanceCents,
  });

  final String username;
  final String password;
  final String displayName;
  final int startingBalanceCents;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      password: json['password'] as String,
      displayName: json['displayName'] as String,
      startingBalanceCents: json['startingBalanceCents'] as int,
    );
  }
}
