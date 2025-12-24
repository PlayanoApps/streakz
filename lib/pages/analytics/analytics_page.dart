import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/components/general/app_bar.dart';
import 'package:habit_tracker/components/general/bottom_gradient.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/pages/analytics/analytics_logic.dart';
import 'package:habit_tracker/pages/analytics/habit%20progress/habit_progress.dart';
import 'package:habit_tracker/pages/analytics/tiles/montly_progress_.dart';
import 'package:habit_tracker/pages/analytics/tiles/small_tile.dart';
import 'package:habit_tracker/pages/analytics/tiles/tile_row.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final AnalyticsLogic logic = AnalyticsLogic();

  int month = DateTime.now().month;
  int year = DateTime.now().year;

  bool backButtonDisabled = false;

  Future<bool> limitReached(int amount) async {
    DateTime? firstLaunchDate =
        await Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).getFirstLaunchDate();

    DateTime newMonthDate = DateTime(year, month + amount);
    DateTime now = DateTime.now();

    if (newMonthDate.isAfter(DateTime(now.year, now.month))) return true;

    if (newMonthDate.isBefore(
      DateTime(firstLaunchDate!.year, firstLaunchDate.month),
    ))
      return true;

    return false;
  }

  void changeMonth(int amount) async {
    bool reached = await limitReached(amount);

    if (reached) return;

    setState(() {
      month += amount;

      // handle wrapping around months and years
      if (month > 12) {
        month = 1;
        year++;
      } else if (month < 1) {
        month = 12;
        year--;
      }
    });

    updateBackButtonVisibility();
  }

  Future<void> updateBackButtonVisibility() async {
    DateTime? firstLaunchDate =
        await Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).getFirstLaunchDate();

    if (firstLaunchDate != null) {
      setState(() {
        backButtonDisabled =
            !DateTime(
              year,
              month,
            ).isAfter(DateTime(firstLaunchDate.year, firstLaunchDate.month));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      // appBar: appBar(context),
      body: Column(
        children: [
          MyAppBar(title: "Analysis", bottomPadding: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _monthNavigator(context, darkMode),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,

                    children: [
                      SizedBox(height: 15), // Distance list view <--> gradient
                      //_monthNavigator(context, darkMode),
                      //SizedBox(height: 15),
                      MonthlyProgressTile(month: month, year: year),
                      SizedBox(height: 15),
                      _tileRow1(context, gap: 15),

                      SizedBox(height: 16),
                      HabitProgress(month: month, year: year),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                MyGradient(height: 40),
                MyGradient(top: true, height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthNavigator(context, darkMode) {
    return Container(
      padding: EdgeInsets.all(9),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _monthNavigateButton(
            context,
            darkMode,
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => changeMonth(-1),
            disable: backButtonDisabled,
          ),

          Text(
            "${numberToMonth(month)} $year",
            style: GoogleFonts.roboto(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withOpacity(darkMode ? 0.8 : 1),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          _monthNavigateButton(
            context,
            darkMode,
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => changeMonth(1),
            disable: DateTime(
              year,
              month + 1,
            ).isAfter(DateTime(DateTime.now().year, DateTime.now().month)),
          ),
        ],
      ),
    );
  }

  Widget _monthNavigateButton(
    context,
    darkMode, {
    required icon,
    required onTap,
    required disable,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disable ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor:
            darkMode
                ? Theme.of(context).colorScheme.surface.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
        highlightColor:
            darkMode
                ? Theme.of(context).colorScheme.surface.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),

        child: Ink(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(
              darkMode ? (disable ? 0.1 : 0.3) : (disable ? 0 : 0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary.withOpacity(
              darkMode ? (disable ? 0.4 : 1) : (disable ? 0 : 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tileRow1(context, {required double gap}) {
    return TileRow(
      gap: gap,
      tile1: SmallTile(
        title: "⚡ Consistency",
        text: "${logic.getConsistency(month, year, context)}%",
        subtext:
            "${logic.getActiveDays(month, year, context)}/${logic.daysInMonth(month, year)} active days",
      ),
      tile2: SmallTile(
        title: "🔥 Streak",
        text: "${logic.getMaxStreak(context)} Days",
        subtext: "best all-time",
      ),
    );
  }

  PreferredSizeWidget? appBar(context) {
    return AppBar(
      title: Center(
        child: Text(
          " A N A L Y T I C S",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () async {
          await Future.delayed(Duration(milliseconds: 100));
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.abc, color: Colors.transparent),
        ),
      ],
    );
  }
}
