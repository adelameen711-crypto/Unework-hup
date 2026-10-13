import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String teamId;
  final String memberId;
  final String raterId;
  final double commitment;
  final double quality;
  final double communication;
  final double leadership;
  final String? comment;
  final DateTime? createdAt;

  RatingModel({
    required this.id,
    required this.teamId,
    required this.memberId,
    required this.raterId,
    required this.commitment,
    required this.quality,
    required this.communication,
    required this.leadership,
    this.comment,
    this.createdAt,
  });

  double get average => (commitment + quality + communication + leadership) / 4;

  factory RatingModel.fromMap(String id, Map<String, dynamic> data) {
    return RatingModel(
      id: id,
      teamId: data['teamId'] ?? '',
      memberId: data['memberId'] ?? '',
      raterId: data['raterId'] ?? '',
      commitment: (data['commitment'] as num?)?.toDouble() ?? 0.0,
      quality: (data['quality'] as num?)?.toDouble() ?? 0.0,
      communication: (data['communication'] as num?)?.toDouble() ?? 0.0,
      leadership: (data['leadership'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'memberId': memberId,
      'raterId': raterId,
      'commitment': commitment,
      'quality': quality,
      'communication': communication,
      'leadership': leadership,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}