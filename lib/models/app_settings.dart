import 'package:isar/isar.dart';

/* 
  To store custom objects in Isar database, we need to create the g file with the following command: 
     flutter pub run build_runner build 
*/
part "app_settings.g.dart";

@Collection()
class AppSettings {
  //Id id = Isar.autoIncrement;
  Id id = 0;  // fixed
  DateTime? firstLaunchDate;

  bool darkModeEnabled = false;

  int selectedColor = 1;      // Accent color / theme

  bool crossCompletedHabits = false;  // Wether completed habit should be highlighed or crossed
}