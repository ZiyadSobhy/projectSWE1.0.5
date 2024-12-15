import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id; // Admin's unique ID (UID from Firebase Auth)
  final String name;
  final String email;
  final List<String> associatedTrainees; // List of trainee UUIDs

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.associatedTrainees,
  });

  // Convert Admin instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'associatedTrainees': associatedTrainees, // List of trainee UUIDs
    };
  }

  // Create an Admin instance from Firestore document
  factory Admin.fromMap(Map<String, dynamic> map, String documentId) {
    return Admin(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      associatedTrainees: List<String>.from(map['associatedTrainees'] ??
          []), // Convert Firestore list to Dart list
    );
  }

  // Save admin to Firestore
  Future<void> saveToFirestore() async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(id);
    await adminRef.set(toMap());
  }

  // Fetch admin from Firestore by ID
  static Future<Admin?> fetchFromFirestore(String adminId) async {
    final adminRef =
        FirebaseFirestore.instance.collection('admins').doc(adminId);
    final snapshot = await adminRef.get();

    if (snapshot.exists) {
      return Admin.fromMap(snapshot.data()!, snapshot.id);
    }
    return null;
  }

  // Add a trainee to the admin's associated list
  Future<void> addTrainee(String traineeId) async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(id);
    associatedTrainees.add(traineeId);
    await adminRef.update({'associatedTrainees': associatedTrainees});
  }

  // Remove a trainee from the admin's associated list
  Future<void> removeTrainee(String traineeId) async {
    final adminRef = FirebaseFirestore.instance.collection('admins').doc(id);
    associatedTrainees.remove(traineeId);
    await adminRef.update({'associatedTrainees': associatedTrainees});
  }
}
