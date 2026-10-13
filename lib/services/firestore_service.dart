import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/task_model.dart';
import '../models/certificate_model.dart';
import '../models/rating_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 👤 USER
  // ============================================================
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<QuerySnapshot> getAllUsers() async {
    return await _firestore.collection('users').get();
  }

  // ============================================================
  // 🏠 TEAM
  // ============================================================
  Future<String> createTeam(TeamModel team) async {
    final ref = await _firestore.collection('teams').add(team.toMap());
    return ref.id;
  }

  Future<TeamModel?> getTeam(String teamId) async {
    final doc = await _firestore.collection('teams').doc(teamId).get();
    if (doc.exists) {
      return TeamModel.fromMap(teamId, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateTeam(String teamId, Map<String, dynamic> data) async {
    await _firestore.collection('teams').doc(teamId).update(data);
  }

  Stream<QuerySnapshot> getTeamsForUser(String uid) {
    return _firestore
        .collection('teams')
        .where('memberIds', arrayContains: uid)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // ============================================================
  // 📋 TASK
  // ============================================================
  Future<String> addTask(String teamId, TaskModel task) async {
    final ref = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .add(task.toMap());
    return ref.id;
  }

  Stream<QuerySnapshot> getTasksForTeam(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .orderBy('position')
        .snapshots();
  }

  Future<void> updateTaskLane(String teamId, String taskId, String newLaneId) async {
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'laneId': newLaneId,
      'history': FieldValue.arrayUnion([
        {'laneId': newLaneId, 'changedAt': FieldValue.serverTimestamp()}
      ]),
    });
  }

  Future<void> updateTaskPosition(String teamId, String taskId, int newPosition) async {
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .doc(taskId)
        .update({'position': newPosition});
  }

  Future<void> deleteTask(String teamId, String taskId) async {
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ============================================================
  // 🎓 CERTIFICATE
  // ============================================================
  Future<String> createCertificate(CertificateModel certificate) async {
    final ref = await _firestore.collection('certificates').add(certificate.toMap());
    return ref.id;
  }

  Stream<QuerySnapshot> getCertificatesForUser(String uid) {
    return _firestore
        .collection('certificates')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // ✅ تم نقل الدوال إلى داخل الكلاس
  Future<void> deleteCertificate(String certificateId) async {
    await _firestore.collection('certificates').doc(certificateId).delete();
  }

  Future<void> verifyCertificate(String certificateId) async {
    await _firestore.collection('certificates').doc(certificateId).update({
      'isVerified': true,
    });
  }

  Future<CertificateModel?> getCertificate(String certificateId) async {
    final doc = await _firestore.collection('certificates').doc(certificateId).get();
    if (doc.exists) {
      return CertificateModel.fromMap(certificateId, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // ============================================================
  // ⭐ RATING
  // ============================================================
  Future<String> createRating(RatingModel rating) async {
    final ref = await _firestore.collection('ratings').add(rating.toMap());
    return ref.id;
  }

  Stream<QuerySnapshot> getRatingsForUser(String uid) {
    return _firestore
        .collection('ratings')
        .where('memberId', isEqualTo: uid)
        .snapshots();
  }

  // ============================================================
  // 🔧 GENERIC
  // ============================================================
  String generateId() => _firestore.collection('temp').doc().id;
}