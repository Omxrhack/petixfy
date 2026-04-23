class User {
  const User({
    required this.id,
    required this.email,
    this.role,
    this.phone,
    required this.isVerified,
    required this.onboardingCompleted,
  });

  final String id;
  final String email;
  final String? role;
  final String? phone;
  final bool isVerified;
  final bool onboardingCompleted;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: json['role']?.toString(),
      phone: json['phone']?.toString(),
      isVerified: json['is_verified'] as bool? ?? false,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }
}
