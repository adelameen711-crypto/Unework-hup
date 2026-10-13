import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? major;
  final int? year;
  final double? gpa;
  final String? profileImageUrl;
  final Map<String, String> skills;
  final List<String> projects;
  final List<String> certificates;
  final double rating;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.major,
    this.year,
    this.gpa,
    this.profileImageUrl,
    this.skills = const {},
    this.projects = const [],
    this.certificates = const [],
    this.rating = 0.0,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? 'مستخدم',
      email: data['email'] ?? '',
      major: data['major'],
      year: data['year'],
      gpa: (data['gpa'] as num?)?.toDouble(),
      profileImageUrl: data['profileImageUrl'],
      skills: Map<String, String>.from(data['skills'] ?? {}),
      projects: List<String>.from(data['projects'] ?? []),
      certificates: List<String>.from(data['certificates'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'major': major,
      'year': year,
      'gpa': gpa,
      'profileImageUrl': profileImageUrl,
      'skills': skills,
      'projects': projects,
      'certificates': certificates,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ✅ دالة copyWith
  UserModel copyWith({
    String? name,
    String? email,
    String? major,
    int? year,
    double? gpa,
    String? profileImageUrl,
    Map<String, String>? skills,
    List<String>? projects,
    List<String>? certificates,
    double? rating,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      major: major ?? this.major,
      year: year ?? this.year,
      gpa: gpa ?? this.gpa,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certificates: certificates ?? this.certificates,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===== دوال مساعدة =====
  int get skillCount => skills.length;
  int get projectCount => projects.length;
  int get certificateCount => certificates.length;

  double get averageSkillLevel {
    if (skills.isEmpty) return 0.0;
    final levels = {'beginner': 1, 'intermediate': 2, 'advanced': 3, 'expert': 4};
    double total = 0.0;
    for (var level in skills.values) {
      total += levels[level.toLowerCase()]?.toDouble() ?? 0.0;
    }
    return total / skills.length;
  }
}