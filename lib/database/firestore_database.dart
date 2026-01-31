import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
//import 'package:isar/isar.dart';
import 'package:isar_community/isar.dart';

/* Firebase also used in Isar database, auth_gate, register and helper functions */

class FirestoreDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Isar isar;

  bool debug = false;

  FirestoreDatabase(this.isar);

  // Habit collection for a specific user
  CollectionReference _habitCollection(User user) {
    return _firestore.collection("Users").doc(user.email).collection("Habits");
  }

  // App settings document for a specific user
  DocumentReference _appSettingsDoc(User user) {
    return _firestore
        .collection("Users")
        .doc(user.email)
        .collection("Settings")
        .doc("appSettings");
  }

  // Weil es Fehler gab dass "Journal/Medidate" als 2 Habits interpretiert wurden
  String _sanitizeHabitName(String name) {
    return name
        .replaceAll('/', '_') // Slash durch Underscore
        .replaceAll('\\', '_') // Backslash durch Underscore
        .replaceAll('.', '_'); // Punkt durch Underscore (falls vorhanden)
  }

  // Upload all habits from Isar into Firestore for a specific user
  // Called in Isar updateHabitsList() fucntion --> whenever list changes, sync with firestore
  Future<void> syncToFirestore(User user, {context = ""}) async {
    try {
      // 1) Load local data from Isar
      final localHabits = await isar.habits.where().findAll();
      final localAppSettings = await isar.appSettings.get(0);

      // 2) Delete everything currently in Firestore
      try {
        final existingDocs = await _habitCollection(user).get();
        final deleteBatch = _firestore.batch();
        for (final doc in existingDocs.docs) {
          deleteBatch.delete(doc.reference);
        }
        await deleteBatch.commit();
      } catch (e) {
        if (debug)
          showCustomDialog(
            context,
            title:
                "syncToFirestore(): Failed to delete existing Firestore data: $e",
          );
      }

      // 3) Upload local habits
      try {
        final uploadBatch = _firestore.batch();
        for (final habit in localHabits) {
          final docRef = _habitCollection(
            user,
          ).doc(_sanitizeHabitName(habit.name));
          uploadBatch.set(docRef, {
            "id": habit.id,
            "name": habit.name,
            "description": habit.description,
            "completedDays":
                habit.completedDays.map((d) => d.toIso8601String()).toList(),
            "archived": habit.isArchived,
            "order": habit.order,
          });
        }

        // 4) Upload app settings
        if (localAppSettings != null) {
          uploadBatch.set(_appSettingsDoc(user), {
            "id": localAppSettings.id,
            "firstLaunchDate":
                localAppSettings.firstLaunchDate?.toIso8601String(),
          });
        }

        await uploadBatch.commit();
      } catch (e) {
        if (debug)
          showCustomDialog(
            context,
            title: "syncToFirestore(): Failed to upload data to Firestore: $e",
          );
      }
    } catch (e) {
      if (debug) {
        Future.delayed(Duration(seconds: 1));
        showCustomDialog(context, title: "Sync to Firestore failed $e");
      }
    }
  }

  // Download all habits from Firestore isar
  // Called in auth gate when user is logged in, before showing home page
  Future<void> loadFromFirestore(User user, context) async {
    List<Habit> firestoreHabits = [];
    AppSettings? firestoreAppSettings;

    try {
      // Download habits
      final habitSnapshot = await _habitCollection(user).get();
      firestoreHabits =
          habitSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Habit()
              ..id = data["id"]
              ..name = data["name"] ?? ""
              ..description = data["description"] ?? ""
              ..isArchived = data["archived"] ?? false
              ..completedDays =
                  (data["completedDays"] as List<dynamic>? ?? [])
                      .map((d) => DateTime.parse(d.toString()))
                      .toList()
              ..order = data["order"] ?? 0;
          }).toList();

      // Download app settings
      final settingsSnapshot = await _appSettingsDoc(user).get();
      if (settingsSnapshot.exists) {
        final data = settingsSnapshot.data() as Map<String, dynamic>;
        firestoreAppSettings =
            AppSettings()
              ..id = data["id"]
              ..firstLaunchDate =
                  data["firstLaunchDate"] != null
                      ? DateTime.parse(data["firstLaunchDate"])
                      : null;
      }

      // Only update Isar if Firestore download was successful
      await isar.writeTxn(() async {
        await isar.habits.clear();
        for (final habit in firestoreHabits) {
          await isar.habits.put(habit);
        }

        // Update app settings if available
        if (firestoreAppSettings != null) {
          await isar.appSettings.put(firestoreAppSettings);
        }
      });
    } catch (e) {
      if (debug)
        showCustomDialog(context, title: "Failed to load data from cloud");
    }
  }
}
