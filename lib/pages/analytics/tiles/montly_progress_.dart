import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/pages/analytics/analytics_logic.dart';
import 'package:habit_tracker/pages/analytics/bar%20graph/bar_graph.dart';
import 'package:habit_tracker/util/habit_helpers.dart';

class MonthlyProgressTile extends StatelessWidget {
  final int month;
  final int year;

  MonthlyProgressTile({super.key, required this.month, required this.year});

  final AnalyticsLogic logic = AnalyticsLogic();

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 22),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow(context, darkMode),

          SizedBox(height: 18),

          _percentagesRow(context),

          SizedBox(height: 20),

          _barGraph(context, lastMonth: month, lastYear: year),
        ],
      ),
    );
  }

  Widget _titleRow(context, darkMode) {
    double percentage = logic.getPercentageIncrease(
      month,
      month - 1,
      year,
      context,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withOpacity(darkMode ? 0.7 : 0.35),
                size: 23,
              ),
              Text(
                "  Monthly Progress",
                style: GoogleFonts.roboto(
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimary.withOpacity(darkMode ? 0.8 : 1),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color:
                  percentage > 0
                      ? darkMode
                          ? Colors.green.shade900.withOpacity(0.5)
                          : Colors.green.shade100.withOpacity(0.9)
                      : darkMode
                      ? Colors.deepOrange.shade600.withOpacity(0.2)
                      : Colors.deepOrange.shade100.withOpacity(0.9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(
                  percentage > 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 16,
                  color:
                      percentage > 0
                          ? darkMode
                              ? Colors.green.shade200
                              : Colors.green.shade500
                          : darkMode
                          ? Colors.deepOrange.shade200
                          : Colors.deepOrange.shade500,
                ),
                SizedBox(width: 2),
                Text(
                  "${logic.getPercentageIncrease(month, month - 1, year, context).abs()}%",
                  style: GoogleFonts.roboto(
                    color:
                        percentage > 0
                            ? darkMode
                                ? Colors.green.shade300
                                : Colors.green.shade500
                            : darkMode
                            ? Colors.deepOrange.shade300
                            : Colors.deepOrange.shade500,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentagesRow(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This month",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${logic.getMonthProgressPercentage(month, year, context)}%",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last month",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${logic.getMonthProgressPercentage(month - 1, year, context)}%",
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _barGraph(context, {required int lastMonth, required lastYear}) {
  AnalyticsLogic logic = AnalyticsLogic();
  //List<double> monthlySummary = [10, 20, 30, 40, 50, 60];

  int currentMonth = DateTime.now().month; // month marked in bar graph
  int currentYear = DateTime.now().year;

  int monthDifference = calculateMonthDifference(
    currentMonth,
    currentYear,
    lastMonth,
    lastYear,
  );

  print("Month dif: $monthDifference");

  /*  if (monthDifference > 6) {
    //currentMonth += (6 - monthDifference);
    currentMonth = shiftMonth(currentMonth, 6 - monthDifference);
  } */

  if (monthDifference > 6) {
    int shift = 6 - monthDifference;
    currentMonth = shiftMonth(currentMonth, shift);

    // Adjust the year when shifting crosses a boundary
    if (shift < 0 && currentMonth > DateTime.now().month)
      currentYear--;
    else if (shift > 0 && currentMonth < DateTime.now().month)
      currentYear++;
  }

  List<double> monthlySummary = logic.getMonthlySummary(
    shiftMonth(currentMonth, -6),
    currentMonth,
    currentYear,
    context,
  );

  print("------------------------------------------------");
  print(
    "start: ${shiftMonth(currentMonth, -6)}, end: $currentMonth, $lastYear",
  );
  print("monthlySummary: $monthlySummary");

  return SizedBox(
    height: 135,
    child: MyBarGraph(
      monthlySummary: monthlySummary,
      lastMonth: lastMonth,
      year: lastYear,
    ),
  );
}


/* Widget _barGraph(context, {required int lastMonth, required int lastYear}) {
  AnalyticsLogic logic = AnalyticsLogic();

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  int monthDifference = calculateMonthDifference(currentMonth, lastMonth);

  print("Month dif: $monthDifference");
  print(
    "Selected: $lastMonth/$lastYear, Current start: $currentMonth/$currentYear",
  );

  // Verschiebe das Fenster nur wenn nötig
  if (monthDifference > 6) {
    int shift = 6 - monthDifference;
    currentMonth = shiftMonth(currentMonth, shift);

    // Wenn currentMonth durch die Verschiebung > 12 wird, sind wir ins nächste Jahr gerutscht
    // Wenn currentMonth durch die Verschiebung <= 0 wird, sind wir ins vorherige Jahr gerutscht
    if (shift < 0 && currentMonth > DateTime.now().month) {
      // Wir sind ins vorherige Jahr gerutscht
      currentYear--;
    } else if (shift > 0 && currentMonth < DateTime.now().month) {
      // Wir sind ins nächste Jahr gerutscht
      currentYear++;
    }
  }

  // Startmonat ist immer 6 Monate vor currentMonth
  int windowStartMonth = shiftMonth(currentMonth, -6);
  int windowStartYear = currentYear;

  // Korrigiere das Jahr für den Startmonat wenn nötig
  if (currentMonth <= 6) {
    windowStartYear--;
  }

  print(
    "Window: $windowStartMonth/$windowStartYear to $currentMonth/$currentYear",
  );

  List<double> monthlySummary = logic.getMonthlySummary(
    windowStartMonth,
    currentMonth,
    currentYear,
    context,
  );

  print("monthlySummary: $monthlySummary");

  return SizedBox(
    height: 135,
    child: MyBarGraph(
      monthlySummary: monthlySummary,
      lastMonth: lastMonth, // Der aktuell ausgewählte Monat
      year: lastYear,
    ),
  );
}
 */