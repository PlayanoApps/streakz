import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/common/custom_dialog.dart';
import 'package:habit_tracker/components/habit/habit_tile.dart';
import 'package:habit_tracker/components/habit/heatmap.dart';
import 'package:habit_tracker/components/common/drawer.dart';
import 'package:habit_tracker/components/habit/showcase.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/noti_service.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {
  //final bool onboarding;
  const HomePage({super.key /* this.onboarding = false */});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _heatmapKey1 = GlobalKey();
  final GlobalKey _heatmapKey2 = GlobalKey();
  final GlobalKey _habitListKey1 = GlobalKey();
  final GlobalKey _habitListKey2 = GlobalKey();
  final GlobalKey _addHabitKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Read habits from Database
    Provider.of<HabitDatabase>(context, listen: false).updateHabitList();
    Provider.of<ThemeProvider>(context, listen: false).loadTheme();
    Provider.of<ThemeProvider>(context, listen: false).loadAccentColor();
    Provider.of<ThemeProvider>(context, listen: false).loadHabitCompletedPref();
    Provider.of<ThemeProvider>(context, listen: false).loadfollowSystemTheme();
    Provider.of<NotiServiceProvider>(
      context,
      listen: false,
    ).loadNotificationSetting();

    handleOnboarding();
  }

  void handleOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("showOnboarding") == false) return;

    // ensure that widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 700));

      ShowCaseWidget.of(context).startShowCase([
        _heatmapKey1,
        _heatmapKey2,
        _habitListKey1,
        _habitListKey2,
        _addHabitKey,
      ]);

      // Delete default habits after showcase --> main
      // Set Onboarding pref to false --> main
    });
  }

  // Boxes
  final TextEditingController textController = TextEditingController();

  void clear() async {
    Navigator.pop(context);
    //textController.clear();
  }

  void createNewHabit() async {
    void saveHabit() {
      String newHabitName = textController.text;
      if (newHabitName != "") {
        Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).addHabit(newHabitName);
        clear();
      }
    }

    await Future.delayed(Duration(milliseconds: 100));
    showCustomDialog(
      context,
      controller: textController,
      hintText: "Create a new habit",
      actions: (clear, saveHabit),
    );
  }

  // Habit actions
  void checkHabitOnOff(bool? value, Habit habit) {
    // Update habit completion status
    if (value != null) {
      HapticFeedback.lightImpact();
      Provider.of<HabitDatabase>(
        context,
        listen: false,
      ).updateHabitCompletion(habit.id, value, DateTime.now());
    }
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    void editHabit(Habit habit) async {
      // Update in db
      String newHabitName = textController.text;
      if (newHabitName != "") {
        Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).updateHabitName(habit.id, newHabitName);
        await Future.delayed(Duration(milliseconds: 100));
        clear();
      }
    }

    showCustomDialog(
      context,
      controller: textController,
      hintText: "New habit name",
      actions: (clear, () => editHabit(habit)),
      zoomTransition: true,
    );
  }

  void deleteHabitBox(Habit habit) {
    void deleteHabit() {
      // Delete in db
      Provider.of<HabitDatabase>(context, listen: false).deleteHabit(habit.id);
      clear();
    }

    showCustomDialog(
      context,
      controller: textController,
      title: "Delete this habit?",
      actions: (clear, deleteHabit),
      labels: ("Cancel", "Delete"),
      zoomTransition: true,
    );
  }

  void reorderTile(List<Habit> habitsList, int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex--;
      final tile = habitsList.removeAt(oldIndex);
      habitsList.insert(newIndex, tile);
    });
    Provider.of<HabitDatabase>(context, listen: false).saveNewHabitOrder();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _appBar(),
      drawer: MyDrawer(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          ListView(
            children: [
              _divider(),
              _buildHeatmap(),
              SizedBox(height: 24), // 16
              _buildHabitList(),
              SizedBox(height: 30),
            ],
          ),
          _bottomGradient(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Center(
        child: Text("S T R E A K Z", style: TextStyle(fontSize: 19)),
      ),
      actions: [
        MyShowcase(
          globalKey: _addHabitKey,
          description: "Add new habits here",
          child: IconButton(
            onPressed: createNewHabit,
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomGradient() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 35,
      child: AbsorbPointer(
        // Block touches (vs IgnorePointer)
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(1),
                Theme.of(context).colorScheme.surface.withOpacity(0),
              ],
              stops: [0.25, 1],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Divider(color: Theme.of(context).colorScheme.secondary, height: 5),
    );
  }

  Widget _buildHeatmap() {
    final database = Provider.of<HabitDatabase>(context);

    return FutureBuilder(
      future: database.getFirstLaunchDate(),

      builder: (context, snapshot) {
        if (snapshot.hasData)
          return MyShowcase(
            globalKey: _heatmapKey2,
            title: "Edit heatmap",
            description:
                "You can long-press on any tile to edit your progress afterwards.",
            child: MyShowcase(
              globalKey: _heatmapKey1,
              title: "Your Progress",
              description:
                  "Your habits are elegantly visualized in a beautiful heatmap. Check out how one month of consistency lights it up! 🔥",
              child: MyHeatmap(startDate: snapshot.data!),
            ),
          );
        else
          return CupertinoActivityIndicator();
      },
    );
  }

  Widget _buildHabitList() {
    final isDarkMode = (Theme.of(context).brightness == Brightness.dark);

    // Get list of habits
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    if (habitsList.where((habit) => !habit.isArchived).isNotEmpty) {
      return MyShowcase(
        globalKey: _habitListKey2,
        title: "Habit Actions",
        description:
            "You can swipe left on a habit to edit or delete it. To reorder, you can long-press.",
        child: MyShowcase(
          globalKey: _habitListKey1,
          title: "Your Habits",
          description:
              "As you check off your habits, the heatmap turns greener ✅",

          child: ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            onReorder: (n, i) => reorderTile(habitsList, n, i),

            children: [
              for (final habit in habitsList)
                habit.isArchived
                    ? SizedBox(key: ValueKey('archived_${habit.name}'))
                    : HabitTile(
                      key: ValueKey(habit.name),
                      habit: habit,
                      isCompleted: habitCompleted(
                        habit.completedDays,
                        DateTime.now(),
                      ),
                      checkboxChanged: (value) => checkHabitOnOff(value, habit),
                      editHabit: (context) => editHabitBox(habit),
                      deleteHabit: (context) => deleteHabitBox(habit),
                    ),
            ],
          ),
        ),
      );
    } else
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 110),
          child: Text(
            "Start by adding your first habit.",
            style: TextStyle(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
              fontSize: 16.2,
            ),
          ),
        ),
      );
  }
}
