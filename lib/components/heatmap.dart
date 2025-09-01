import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/dialog_box.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import "../_heatmap_calendar/flutter_heatmap_calendar.dart";

/* class MyHeatmap extends StatelessWidget {
  final DateTime startDate;

  const MyHeatmap({
    super.key,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {

    //bool darkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: HeatMapCalendar(
        datasets: prepDataset(context),
      
        colorMode: ColorMode.color,
        defaultColor: Theme.of(context).colorScheme.secondary,

        highlightedColor: !darkMode ? const Color.fromARGB(255, 230, 230, 230)  // def. 38
                                    : Theme.of(context).colorScheme.secondary,
        highlightedBorderColor: !darkMode ? Color.fromARGB(255, 238, 238, 238)
                                    : Color.fromARGB(255, 70, 70, 70),
        highlightedBorderWith: !darkMode? 2 : 1.5,

        textColor: Theme.of(context).colorScheme.tertiary,
        showColorTip: false,
        flexible: true,
        monthFontSize: 16,
        fontSize: 15.5, // prev 15,5
        weekTextColor: Theme.of(context).colorScheme.primary,
        onClick: (date) => showEditHeatmapDialog(date, context),

        borderRadius: 6,
      
        colorsets: prepColorsets(context),
      ),
    );
  }
}

// Prepare heat map colorsets
Map<int, Color> prepColorsets(BuildContext context) {
  int habitsAmount = Provider.of<HabitDatabase>(context).habitsList.length;

  if (habitsAmount <= 0)
    return {};

  int alpha = 130 - (habitsAmount * 10);   // min alpha for first habit (more habits --> less)
  // if min alpha becomes negative, set to 0
  if (alpha < 0) alpha = 0;

  int maxAlpha = 230;                     // Don't exceed this value
  Color accentColor = Provider.of<ThemeProvider>(context).getAccentColor();

  if (habitsAmount == 1)
    return { 1: accentColor.withAlpha(maxAlpha) };

  Map<int, Color> colorset = {};
  int incrementStep = habitsAmount > 1 ? ((maxAlpha - alpha) / (habitsAmount - 1)).toInt() : 0;

  for (int i = 1; i <= habitsAmount; i++) {
    // Start first habit with initial alpha. Then, increment
    alpha = (i == 1) ? alpha : min(alpha + incrementStep, maxAlpha);
    colorset[i] = accentColor.withAlpha(alpha); 
  }
  return colorset;
}

// Prepare heat map dataset
Map<DateTime, int> prepDataset(BuildContext context) {
  List<Habit> habits = Provider.of<HabitDatabase>(context).habitsList;

  Map<DateTime, int> dataset = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      // Normalize date to avoid time mismatch
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // If the day already exists in the dataset, increment
      if (dataset.containsKey(normalizedDate))
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      else
        dataset[normalizedDate] = 1; 
    }
  }
  return dataset;
} */

class MyHeatmap extends StatefulWidget {
  final DateTime startDate;
  final bool animate;
  final Duration animationDuration;

  const MyHeatmap({
    super.key,
    required this.startDate,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 2500), // Good pace for one-by-one effect
  });

  @override
  State<MyHeatmap> createState() => _MyHeatmapState();
}

class _MyHeatmapState extends State<MyHeatmap> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    } else 
      _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void restartAnimation() {
    if (widget.animate) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    HeatmapAnimation animation = HeatmapAnimation();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return RepaintBoundary(
            child: HeatMapCalendar(
              datasets: animation.prepAnimatedDataset(context, _animation.value),
              colorsets: animation.prepAnimatedColorsets(context, _animation.value),
              
              colorMode: ColorMode.color,
              defaultColor: Theme.of(context).colorScheme.secondary,

              highlightedColor: !darkMode ? const Color.fromARGB(255, 230, 230, 230)
                                          : Theme.of(context).colorScheme.secondary,
              highlightedBorderColor: !darkMode ? Color.fromARGB(255, 238, 238, 238)
                                          : Color.fromARGB(255, 70, 70, 70),
              highlightedBorderWith: !darkMode? 2 : 1.5,

              textColor: Theme.of(context).colorScheme.tertiary,
              showColorTip: false,
              flexible: true,
              monthFontSize: 16,
              fontSize: 15.5,
              weekTextColor: Theme.of(context).colorScheme.primary,
              onClick: (date) => showEditHeatmapDialog(date, context),

              borderRadius: 6,
            ),
          );
        },
      ),
    );
  }
}

class HeatmapAnimation {
  // Prepare animated colorsets with smooth fade transitions
  Map<int, Color> prepAnimatedColorsets(BuildContext context, double animationValue) {
    
    int habitsAmount = Provider.of<HabitDatabase>(context).habitsList.length;
    List<Habit> habits = Provider.of<HabitDatabase>(context).habitsList;

    if (habitsAmount <= 0) return {};

    // Base color calculation
    int alpha = 130 - (habitsAmount * 10);
    if (alpha < 0) alpha = 0;

    // Set max alpha
    int maxAlpha = 230;

    // Get all completion dates for animation timing
    Set<DateTime> allDates = {};
    for (var habit in habits) {
      for (var date in habit.completedDays) {
        allDates.add(DateTime(date.year, date.month, date.day));
      }
    }
    
    List<DateTime> sortedDates = allDates.toList()
      ..sort((a, b) => a.compareTo(b));

    Color accentColor = Provider.of<ThemeProvider>(context).getAccentColor();
    Color baseColor = Theme.of(context).colorScheme.secondary;

    if (habitsAmount == 1) {
      // Single habit - fade from transparent to full color
      /* double fadeOpacity = _calculateDateOpacity(sortedDates, animationValue, DateTime.now());
      Color fullColor = accentColor.withAlpha(maxAlpha);
      return { 
        1: Color.lerp(baseColor.withOpacity(0.1), fullColor, fadeOpacity) ?? fullColor 
      }; */
      return { 1: accentColor.withAlpha(maxAlpha-80) };
    }

    Map<int, Color> animatedColorsets = {};
    int incrementStep = habitsAmount > 1 ? ((maxAlpha - alpha) / (habitsAmount - 1)).toInt() : 0;

    for (int i = 1; i <= habitsAmount; i++) {
      int currentAlpha = (i == 1) ? alpha : min(alpha + incrementStep * (i - 1), maxAlpha);
      Color targetColor = accentColor.withAlpha(currentAlpha);
      
      // Calculate average fade opacity for this intensity level
      double totalOpacity = 0.0;
      int count = 0;
      
      // Get current animated dataset to see which dates are at this intensity
      Map<DateTime, int> currentDataset = prepAnimatedDataset(context, animationValue);
      currentDataset.forEach((date, value) {
        if (value == i) {
          totalOpacity += _calculateDateOpacity(sortedDates, animationValue, date);
          count++;
        }
      });
      
      double avgOpacity = count > 0 ? totalOpacity / count : 0.0;
      
      // Smooth fade from base color to target color
      animatedColorsets[i] = Color.lerp(
        baseColor.withOpacity(0.15), 
        targetColor, 
        avgOpacity
      ) ?? targetColor;
    }
    
    return animatedColorsets;
  }

  // Calculate smooth opacity for a specific date based on animation progress
  double _calculateDateOpacity(List<DateTime> sortedDates, double animationValue, DateTime targetDate) {
    if (sortedDates.isEmpty) return 0.0;
    
    int dateIndex = sortedDates.indexOf(targetDate);
    if (dateIndex == -1) return 0.0;
    
    // ADJUST THESE VALUES TO CONTROL FADE TIMING:
    double staggerAmount = 0.15;  
    double fadeInDuration = 1; 
    
    double dateStartProgress = (dateIndex / sortedDates.length) * staggerAmount;
    double dateEndProgress = (dateStartProgress + fadeInDuration).clamp(0.0, 1.0);
    
    if (animationValue <= dateStartProgress) {
      return 0.0; // Not started yet
    } else if (animationValue >= dateEndProgress) {
      return 1.0; // Fully visible
    } else {
      // Quick, snappy fade-in
      double fadeProgress = (animationValue - dateStartProgress) / fadeInDuration;
      return Curves.easeOutQuart.transform(fadeProgress); // Snappier curve
    }
  }

  // Prepare animated dataset - always include all dates but control visibility via colors
  Map<DateTime, int> prepAnimatedDataset(BuildContext context, double animationValue) {
    List<Habit> habits = Provider.of<HabitDatabase>(context).habitsList;

    Map<DateTime, int> dataset = {};

    for (var habit in habits) {
      for (var date in habit.completedDays) {
        final normalizedDate = DateTime(date.year, date.month, date.day);

        if (dataset.containsKey(normalizedDate))
          dataset[normalizedDate] = dataset[normalizedDate]! + 1;
        else
          dataset[normalizedDate] = 1; 
      }
    }
    
    // Always return all data - opacity is controlled by colors
    return dataset;
  }
}