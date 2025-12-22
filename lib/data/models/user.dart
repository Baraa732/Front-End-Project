class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'tenant', 'landlord', 'admin'
  final String? phone;
  final String? avatar;
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.avatar,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'tenant',
      phone: json['phone'],
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'is_verified': isVerified,
    };
  }
}