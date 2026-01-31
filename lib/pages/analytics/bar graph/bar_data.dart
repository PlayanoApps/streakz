import 'package:habit_tracker/pages/analytics/bar%20graph/individual_bar.dart';

class BarData {
  final double month0;
  final double month1;
  final double month2;
  final double month3;
  final double month4;
  final double month5;
  final double month6;

  BarData({
    required this.month0,
    required this.month1,
    required this.month2,
    required this.month3,
    required this.month4,
    required this.month5,
    required this.month6,
  });

  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = [
      IndividualBar(x: 0, y: month0),
      IndividualBar(x: 1, y: month1),
      IndividualBar(x: 2, y: month2),
      IndividualBar(x: 3, y: month3),
      IndividualBar(x: 4, y: month4),
      IndividualBar(x: 5, y: month5),
      IndividualBar(x: 6, y: month6),
    ];
  }
}
