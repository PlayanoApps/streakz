import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/analytics/bar%20graph/bar_data.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:habit_tracker/util/habit_helpers.dart';
import 'package:provider/provider.dart';

class MyBarGraph extends StatelessWidget {
  final List monthlySummary; // [ octAmount, sepAmount,.. ]
  final int lastMonth;
  final int year;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.lastMonth,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    BarData barData = BarData(
      month0: monthlySummary[0],
      month1: monthlySummary[1],
      month2: monthlySummary[2],
      month3: monthlySummary[3],
      month4: monthlySummary[4],
      month5: monthlySummary[5],
      month6: monthlySummary[6],
    );

    barData.initializeBarData();

    MaterialColor accentColor =
        Provider.of<ThemeProvider>(context).getAccentColor();
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    int shiftAmount = calculateMonthDifference(
      DateTime.now().month,
      DateTime.now().year,
      lastMonth,
      year,
    );
    if (shiftAmount > 6) shiftAmount -= (shiftAmount - 6);
    //shiftAmount = shiftMonth(shiftAmount, 6 - shiftAmount);

    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) => getBottomTitles(value, meta, darkMode),
            ),
          ),
        ),

        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: EdgeInsets.all(8),
            tooltipMargin: 10,
            getTooltipColor:
                (data) =>
                    (data.x == 6 - shiftAmount)
                        ? accentColor[500]!.withOpacity(0.8)
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(darkMode ? 0.9 : 0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}%',
                TextStyle(
                  color: Colors.grey.shade100, // 👈 text color
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              );
            },
          ),
        ),

        barGroups:
            barData.barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.x,

                    barRods: [
                      BarChartRodData(
                        toY: data.y,
                        color:
                            data.x == 6 - shiftAmount
                                ? accentColor[500]
                                : Theme.of(context).colorScheme.primary
                                    .withOpacity(darkMode ? 0.6 : 0.5),
                        width: 23,
                        borderRadius: BorderRadius.circular(30),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Theme.of(context).colorScheme.primary
                              .withOpacity(darkMode ? 0.2 : 0.1),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta, bool darkMode) {
    var style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    int currentMonth = DateTime.now().month;

    int monthDifference = calculateMonthDifference(
      currentMonth,
      DateTime.now().year,
      lastMonth,
      year,
    );

    if (monthDifference > 6)
      currentMonth = shiftMonth(currentMonth, 6 - monthDifference);
    //currentMonth += (6 - monthDifference);

    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -6))[0],
          style: style,
        );
        //print("Current month: $currentMonth");
        //print("${shiftMonth(currentMonth, -6)}");
        break;
      case 1:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -5))[0],
          style: style,
        );
        break;
      case 2:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -4))[0],
          style: style,
        );
        break;
      case 3:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -3))[0],
          style: style,
        );
        break;
      case 4:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -2))[0],
          style: style,
        );
        break;
      case 5:
        text = Text(
          numberToMonth(shiftMonth(currentMonth, -1))[0],
          style: style,
        );
        break;
      case 6:
        text = Text(numberToMonth(currentMonth)[0], style: style);
        break;
      default:
        text = Text("bar_graph default case");
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, child: text);
  }
}
