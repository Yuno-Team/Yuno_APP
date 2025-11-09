class User {
  final String id;
  final String email;
  final String name;
  final DateTime? birthDate;
  final String? region;
  final String? school;
  final String? education;
  final String? major;
  final List<String> interests;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.birthDate,
    this.region,
    this.school,
    this.education,
    this.major,
    this.interests = const [],
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      region: json['region'],
      school: json['school'],
      education: json['education'],
      major: json['major'],
      interests: List<String>.from(json['interests'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'region': region,
      'school': school,
      'education': education,
      'major': major,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? birthDate,
    String? region,
    String? school,
    String? education,
    String? major,
    List<String>? interests,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      region: region ?? this.region,
      school: school ?? this.school,
      education: education ?? this.education,
      major: major ?? this.major,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
