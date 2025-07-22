import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/dialog_box.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/heatmap.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/settings_page.dart';
import 'package:habit_tracker/services/noti_service.dart';
import 'package:habit_tracker/theme_provider.dart';
import 'package:habit_tracker/util/helper_functions.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final bool showThemes;
  const HomePage({super.key, this.showThemes = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {

    /* Load the data inside of widget */
    
    // Read habits from db into habit list on startup
    Provider.of<HabitDatabase>(context, listen: false).updateHabitList();
    Provider.of<ThemeProvider>(context, listen: false).loadTheme();
    Provider.of<ThemeProvider>(context, listen: false).loadAccentColor();
    Provider.of<ThemeProvider>(context, listen: false).loadHabitCompletedPref();
    Provider.of<ThemeProvider>(context, listen: false).loadUseSystemTheme();
    Provider.of<NotiServiceProvider>(context, listen: false).loadNotificationSetting();

    super.initState();

    if (widget.showThemes) {
      // ensure that widget is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showThemes();
      });
    }
  }

  void showThemes() async {
    void openThemeSettings() {
      Navigator.pop(context); // First dismiss the dialog
      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(showThemes: true)));
    }
    await Future.delayed(Duration(seconds: 3));
    showCustomDialog(
      context: context,
      title: "Select a theme!",
      text: "Personalize the look of the app to make it feel just right for you.",
      labels: ("Not now", "Yes!"),
      actions: (() => Navigator.pop(context), openThemeSettings),
      zoomTransition: true
    );
  }


  // text controller
  final TextEditingController textController = TextEditingController();

  void clear() {
    Navigator.pop(context);
    textController.clear();
  }

  void createNewHabit() async {
    void saveHabit() {
      String newHabitName = textController.text;
      if (newHabitName != "") {
        Provider.of<HabitDatabase>(context, listen: false).addHabit(newHabitName);
        clear(); 
      }
    }
  	await Future.delayed(Duration(milliseconds: 100));
    showCustomDialog(
      context: context,
      controller: textController,
      hintText: "Create a new habit",
      actions: (clear, saveHabit)
    );
  }

  /* Functions to pass to HabitTile Widget */

  void checkHabitOnOff(bool? value, Habit habit) {
    // Update habit completion status
    if (value != null) {
      HapticFeedback.mediumImpact(); 
      Provider.of<HabitDatabase>(context, listen: false)
        .updateHabitCompletion(habit.id, value, DateTime.now());
    }
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    void editHabit(Habit habit) async {     // Update in db
      String newHabitName = textController.text;
      if (newHabitName != "") {
        Provider.of<HabitDatabase>(context, listen: false).updateHabitName(habit.id, newHabitName);  
        await Future.delayed(Duration(milliseconds: 100));
        clear();
      }
    }
    showCustomDialog(
      context: context,
      controller: textController,
      hintText: "New habit name",
      actions: (clear, () => editHabit(habit)),
    );
  }

  void deleteHabitBox(Habit habit) {
    void deleteHabit() {  // Delete in db
      Provider.of<HabitDatabase>(context, listen: false)
        .deleteHabit(habit.id); 
      clear();
    }

    showCustomDialog(
      context: context, 
      controller: textController, 
      title: "Delete this habit?",
      actions: (clear, deleteHabit),
      labels: ("Cancel", "Delete")
    );
  }

  void reorderTile(List<Habit> habitsList, int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex)
        newIndex--;
      final tile = habitsList.removeAt(oldIndex);
      habitsList.insert(newIndex, tile);
    });
    Provider.of<HabitDatabase>(context, listen: false)
      .saveNewHabitOrder();
  }


  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery. of (context).size.width;
    print(deviceWidth);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Center(
          child: Text("S T R E A K Z", style: TextStyle(fontSize: 19))
        ),
        actions: [
          IconButton(
            onPressed: createNewHabit, 
            icon: Icon(Icons.add, 
              color: Theme.of(context).colorScheme.inversePrimary)
          ) 
        ],
      ),

      drawer: MyDrawer(),
      drawerEnableOpenDragGesture: false,

      /* body: ListView(
        children: deviceWidth < 600 ? [
          _divider(),
          _buildHeatmap(),
          SizedBox(height: 15),
          _buildHabitList(),
          SizedBox(height: 30)
        ] : [
          _divider(),
          Row(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              deviceWidth > 900 ? Flexible(flex: 1, child: Container()) : SizedBox(),
              Flexible(flex: 5, child: _buildHeatmap()),
              Flexible(flex: 4, child: Padding(
                padding: const EdgeInsets.only(top: 55),
                child: _buildHabitList(),
              )),
              deviceWidth > 900 ? Flexible(flex: 1, child: Container()) : SizedBox(),
            ],
          )
        ]
      ) */
      body: Stack(
        children: [
          ListView(
            children: [
              _divider(),
              _buildHeatmap(),
              SizedBox(height: 16),   // 15
              _buildHabitList(),
              SizedBox(height: 30),
            ]
          ),
          _bottomGradient()
        ],
      ),
    );
  }

  Widget _bottomGradient() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 25,
      child: IgnorePointer( // So it doesn’t block touches
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0),
              ],
              stops: [0, 1]
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Divider(
        color: Theme.of(context).colorScheme.secondary,
        height: 5,
      ),
    );
  }

  Widget _buildHeatmap() {
    final database =  Provider.of<HabitDatabase>(context);

    // Return heatmap, otherwise container
    return FutureBuilder(
      future: database.getFirstLaunchDate(), 

      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHeatmap(
            startDate: snapshot.data!,
          );
        } else 
          return Container();
      }
    );
  }

  Widget _buildHabitList() {
    // Get list of habits
    List<Habit> habitsList = Provider.of<HabitDatabase>(context).habitsList;

    if (habitsList.isNotEmpty) {
      return ReorderableListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        onReorder: (n, i) => reorderTile(habitsList, n, i),
        children: [ 
          for (final habit in habitsList) 
            HabitTile(
              key: ValueKey(habit.name),
              habit: habit,
              isCompleted: habitCompleted(habit.completedDays, DateTime.now()),
              checkboxChanged: (value) => checkHabitOnOff(value, habit),
              editHabit: (context) => editHabitBox(habit),
              deleteHabit: (context) => deleteHabitBox(habit)
            ) 
        ]
        
      );
      return ListView.builder(
        itemCount: habitsList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),

        itemBuilder: (context, index) {
          final habit = habitsList[index];
          bool isCompletedToday = habitCompleted(habit.completedDays, DateTime.now());

          return HabitTile(
            habit: habit, 
            isCompleted: isCompletedToday,
            checkboxChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        }
      );
    }
      
    else return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Text(
          "No habits found.",
          style: TextStyle(
            color: Provider.of<ThemeProvider>(context).isDarkMode ? 
              Colors.grey[600] : Colors.grey[500],
            fontSize: 16.2
          ),
        ),
      )
    );
  }
}

