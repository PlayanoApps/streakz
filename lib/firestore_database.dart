import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Isar isar;

  FirestoreDatabase(this.isar);

  // Habit collection for a specific user
  CollectionReference _habitCollection(User user) {
    return _firestore
        .collection("Users")
        .doc(user.email)
        .collection("Habits");
  }

  // Upload all habits from Isar into Firestore for a specific user
  // Called in Isar updateHabitsList() fucntion --> whenever list changes, sync with firestore
  Future<void> syncToFirestore(User user) async {

    // 1) Load local habits from Isar
    final localHabits = await isar.habits.where().findAll();

    // 2) Delete everything currently in Firestore
    final existingDocs = await _habitCollection(user).get();
    final deleteBatch = _firestore.batch();
    for (final doc in existingDocs.docs) {
      deleteBatch.delete(doc.reference);
    }
    await deleteBatch.commit();

    // 3) Upload local habits
    final uploadBatch = _firestore.batch();
    for (final habit in localHabits) {
      final docRef = _habitCollection(user).doc(habit.name);
      uploadBatch.set(docRef, {
        "id": habit.id,
        "name": habit.name,
        "description": habit.description,
        "completedDays":
            habit.completedDays.map((d) => d.toIso8601String()).toList(),
        "order": habit.order,
      });
    }
    await uploadBatch.commit();
  }

  // Download all habits from Firestore for a specific user
  // Called in auth gate when user is logged in, before showing home page
  Future<void> downloadHabitsToIsar(User user) async {
    final snapshot = await _habitCollection(user).get();

    final firestoreHabits = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Habit()
        ..id = data["id"]
        ..name = data["name"] ?? ""
        ..description = data["description"] ?? ""
        ..completedDays = (data["completedDays"] as List<dynamic>? ?? [])
            .map((d) => DateTime.parse(d.toString()))
            .toList()
        ..order = data["order"] ?? 0;
    }).toList();

    // ALWAYS clear and update, even if Firestore has no habits
    await isar.writeTxn(() async {
      await isar.habits.clear();
      for (final habit in firestoreHabits) {
        await isar.habits.put(habit);
      }
    });
  }

  /* Future<void> downloadHabitsToIsar(User user) async {
    final snapshot = await _habitCollection(user).get();

    final firestoreHabits = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Habit()
        ..id = data["id"]
        ..name = data["name"] ?? ""
        ..description = data["description"] ?? ""
        ..completedDays = (data["completedDays"] as List<dynamic>? ?? [])
            .map((d) => DateTime.parse(d.toString()))
            .toList()
        ..order = data["order"] ?? 0;
    }).toList();

    // Overwrite local habits only if Firestore has habits
    if (firestoreHabits.isEmpty) return;

    await isar.writeTxn(() async {
      await isar.habits.clear();
      for (final habit in firestoreHabits) {
        await isar.habits.put(habit);
      }
    });
  } */
}