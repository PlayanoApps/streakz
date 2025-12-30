/* import 'package:flutter/material.dart';
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
            "${logic.getActiveDays(month, year, context)}/${(month == DateTime.now().month && year == DateTime.now().year) ? DateTime.now().day : logic.daysInMonth(month, year)} active days",
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
 */

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
  // ============================================================================
  // ANIMATION CONFIGURATION - Adjust these values to customize animations
  // ============================================================================

  // Page entry animation
  static const Duration _pageAnimationDuration = Duration(milliseconds: 500);
  static const Curve _pageAnimationCurve = Curves.easeOut;
  static const double _pageSlideDistance = 20.0; // pixels to slide from bottom

  // Button transition animation
  static const Duration _buttonAnimationDuration = Duration(milliseconds: 300);
  static const Curve _buttonAnimationCurve = Curves.easeInOut;
  static const double _disabledButtonOpacity = 0.3;
  static const double _enabledButtonOpacity = 1.0;

  // ============================================================================

  final AnalyticsLogic logic = AnalyticsLogic();

  int month = DateTime.now().month;
  int year = DateTime.now().year;
  bool backButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    // Initialize back button state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateBackButtonVisibility();
    });
  }

  Future<bool> limitReached(int amount) async {
    final firstLaunchDate =
        await Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).getFirstLaunchDate();

    if (firstLaunchDate == null) return false;

    final newMonthDate = DateTime(year, month + amount);
    final now = DateTime.now();

    // Check if trying to go into the future
    if (newMonthDate.isAfter(DateTime(now.year, now.month))) {
      return true;
    }

    // Check if trying to go before first launch
    if (newMonthDate.isBefore(
      DateTime(firstLaunchDate.year, firstLaunchDate.month),
    )) {
      return true;
    }

    return false;
  }

  void changeMonth(int amount) async {
    final reached = await limitReached(amount);
    if (reached) return;

    setState(() {
      month += amount;

      // Handle month/year wrapping
      if (month > 12) {
        month = 1;
        year++;
      } else if (month < 1) {
        month = 12;
        year--;
      }
    });

    // Update button visibility after month change
    updateBackButtonVisibility();
  }

  Future<void> updateBackButtonVisibility() async {
    final firstLaunchDate =
        await Provider.of<HabitDatabase>(
          context,
          listen: false,
        ).getFirstLaunchDate();

    if (firstLaunchDate == null) return;

    setState(() {
      backButtonDisabled =
          !DateTime(
            year,
            month,
          ).isAfter(DateTime(firstLaunchDate.year, firstLaunchDate.month));
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // AppBar without animation to prevent Ink issues
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: _pageAnimationDuration,
            curve: _pageAnimationCurve,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: MyAppBar(title: "Analysis", bottomPadding: 20),
          ),

          // Content with slide animation
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: _pageAnimationDuration,
              curve: _pageAnimationCurve,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, _pageSlideDistance * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              SizedBox(height: 15),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthNavigator(BuildContext context, bool darkMode) {
    return Container(
      padding: const EdgeInsets.all(9),
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
    BuildContext context,
    bool darkMode, {
    required IconData icon,
    required VoidCallback onTap,
    required bool disable,
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
        child: AnimatedContainer(
          duration: _buttonAnimationDuration,
          curve: _buttonAnimationCurve,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(
              darkMode ? (disable ? 0.1 : 0.3) : (disable ? 0 : 0.15),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedOpacity(
            duration: _buttonAnimationDuration,
            curve: _buttonAnimationCurve,
            opacity: disable ? _disabledButtonOpacity : _enabledButtonOpacity,
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(
                darkMode ? (disable ? 0.4 : 1) : (disable ? 0 : 1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tileRow1(BuildContext context, {required double gap}) {
    final now = DateTime.now();
    final isCurrentMonth = month == now.month && year == now.year;
    final activeDaysTotal =
        isCurrentMonth ? now.day : logic.daysInMonth(month, year);

    return TileRow(
      gap: gap,
      tile1: SmallTile(
        title: "⚡ Consistency",
        text: "${logic.getConsistency(month, year, context)}%",
        subtext:
            "${logic.getActiveDays(month, year, context)}/$activeDaysTotal active days",
      ),
      tile2: SmallTile(
        title: "🔥 Streak",
        text: "${logic.getMaxStreak(context)} Days",
        subtext: "best all-time",
      ),
    );
  }
}
