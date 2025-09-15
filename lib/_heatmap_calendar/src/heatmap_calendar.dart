import 'package:flutter/material.dart';
import 'package:habit_tracker/habit_database.dart';
import 'package:provider/provider.dart';
import 'data/heatmap_color_mode.dart';
import 'widget/heatmap_calendar_page.dart';
import 'widget/heatmap_color_tip.dart';
import 'util/date_util.dart';
import 'util/widget_util.dart';

class HeatMapCalendar extends StatefulWidget {
  /// The datasets which fill blocks based on its value.
  final Map<DateTime, int>? datasets;

  /// The color value of every block's default color.
  final Color? defaultColor;
  final Color? highlightedColor;
  final double? highlightedBorderWith;
  final Color? highlightedBorderColor;

  /// The colorsets which give the color value for its thresholds key value.
  ///
  /// Be aware that first Color is the maximum value if [ColorMode] is [ColorMode.opacity].
  /// Also colorsets must have at least one color.
  final Map<int, Color> colorsets;

  /// The double value of every block's borderRadius.
  final double? borderRadius;

  /// The date values of initial year and month.
  final DateTime? initDate;

  /// The double value of every block's size.
  final double? size;

  /// The text color value of every blocks.
  final Color? textColor;

  /// The double value of every block's fontSize.
  final double? fontSize;

  /// The double value of month label's fontSize.
  final double? monthFontSize;

  /// The double value of week label's fontSize.
  final double? weekFontSize;

  /// The text color value of week labels.
  final Color? weekTextColor;

  /// Make block size flexible if value is true.
  ///
  /// Default value is false.
  final bool? flexible;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// ColorMode changes the color mode of blocks.
  ///
  /// [ColorMode.opacity] requires just one colorsets value and changes color
  /// dynamically based on hightest value of [datasets].
  /// [ColorMode.color] changes colors based on [colorsets] thresholds key value.
  ///
  /// Default value is [ColorMode.opacity].
  final ColorMode colorMode;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime)? onClick;

  /// Function that will be called when month is changed.
  ///
  /// Paratmeter gives [DateTime] value of current month.
  final Function(DateTime)? onMonthChange;

  /// Show color tip which represents the color range at the below.
  ///
  /// Default value is true.
  final bool? showColorTip;

  /// Widgets which shown at left and right side of colorTip.
  ///
  /// First value is the left side widget and second value is the right side widget.
  /// Be aware that [colorTipHelper.length] have to greater or equal to 2.
  /// Give null value makes default 'less' and 'more' [Text].
  final List<Widget?>? colorTipHelper;

  /// The integer value which represents the number of [HeatMapColorTip]'s tip container.
  final int? colorTipCount;

  /// The double value of [HeatMapColorTip]'s tip container's size.
  final double? colorTipSize;

  const HeatMapCalendar({
    super.key,
    required this.colorsets,
    this.colorMode = ColorMode.opacity,
    this.defaultColor,

    this.highlightedColor,  // new
    this.highlightedBorderWith,
    this.highlightedBorderColor,

    this.datasets,
    this.initDate,
    this.size = 42,
    this.fontSize,
    this.monthFontSize,
    this.textColor,
    this.weekFontSize,
    this.weekTextColor,
    this.borderRadius,
    this.flexible = false,
    this.margin,
    this.onClick,
    this.onMonthChange,
    this.showColorTip = true,
    this.colorTipHelper,
    this.colorTipCount,
    this.colorTipSize,
  });

  @override
  State<StatefulWidget> createState() => _HeatMapCalendar();
}

class _HeatMapCalendar extends State<HeatMapCalendar> {
  // The DateTime value of first day of the current month.
  DateTime? _currentDate;

  /* NEW */
  DateTime? _firstLaunchDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      // Set _currentDate value to first day of initialized date or
      // today's month if widget.initDate is null.
      _currentDate =
          DateUtil.startDayOfMonth(widget.initDate ?? DateTime.now());
    });
    /* NEW */
    _loadFirstLaunchDate(); 
  }

  Future<void> _loadFirstLaunchDate() async {
    final db = Provider.of<HabitDatabase>(context, listen: false);
    final launchDate = await db.getFirstLaunchDate();
    print("-----------------------------------------------------------");
    print(launchDate!.day);
    if (!mounted) return;

    setState(() {
      _firstLaunchDate = launchDate;
    });
  }

  bool isAtFirstLaunchMonth() {
    if (_firstLaunchDate == null || _currentDate == null) return false;

    return _currentDate!.year == _firstLaunchDate!.year &&
          _currentDate!.month == _firstLaunchDate!.month;
  }

  bool monthsInFuture(int amount) {
    return _currentDate!.month == (DateTime.now().month + amount);
  }

  void changeMonth(int direction) {
    setState(() {
      _currentDate =
          DateUtil.changeMonth(_currentDate ?? DateTime.now(), direction);
    });
    if (widget.onMonthChange != null) widget.onMonthChange!(_currentDate!);
  }

  /* Future<DateTime?> getFirstMonth() async {
    final db = Provider.of<HabitDatabase>(context, listen: false);
    final launchDate = await db.getFirstLaunchDate();

    return launchDate;
  } */

  /// Header widget which shows left, right buttons and year/month text.
  Widget _header(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Previous month button.
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 14,
            color: isAtFirstLaunchMonth() ? Theme.of(context).colorScheme.primary.withAlpha(100) : Theme.of(context).colorScheme.inversePrimary
          ),
          onPressed: isAtFirstLaunchMonth() ? null : () => changeMonth(-1),
        ),

        // Text which shows the current year and month
        Text(
          '${DateUtil.MONTH_LABEL[_currentDate?.month ?? 0]} ${_currentDate?.year}',
          style: TextStyle(
            fontSize: widget.monthFontSize ?? 12,
            color: Theme.of(context).colorScheme.onPrimary
          ),
        ),

        // Next month button.
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: monthsInFuture(2) ? Theme.of(context).colorScheme.primary.withAlpha(100) : Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: monthsInFuture(2) ? null : () => changeMonth(1),
        ),
      ],
    );
  }

  Widget _weekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (String label in DateUtil.WEEK_LABEL.skip(1))
          WidgetUtil.flexibleContainer(
            widget.flexible ?? false,
            false,
            Container(
              margin: EdgeInsets.only(
                  left: widget.margin?.left ?? 2,
                  right: widget.margin?.right ?? 2),
              width: widget.size ?? 42,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: widget.weekFontSize ?? 12,
                  color: widget.weekTextColor ?? const Color(0xFF758EA1),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Expand width dynamically if [flexible] is true.
  Widget _intrinsicWidth({
    required Widget child,
  }) =>
      (widget.flexible ?? false) ? child : IntrinsicWidth(child: child);

  @override
  Widget build(BuildContext context) {
    return _intrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _header(context),
          _weekLabel(),
          HeatMapCalendarPage(
            baseDate: _currentDate ?? DateTime.now(),
            colorMode: widget.colorMode,
            flexible: widget.flexible,
            size: widget.size,
            fontSize: widget.fontSize,
            defaultColor: widget.defaultColor,

            highlightedColor: widget.highlightedColor,
            highlightedBorderWith: widget.highlightedBorderWith,
            highlightedBorderColor: widget.highlightedBorderColor,

            textColor: widget.textColor,
            margin: widget.margin,
            datasets: widget.datasets,
            colorsets: widget.colorsets,
            borderRadius: widget.borderRadius,
            onClick: widget.onClick,
          ),
          if (widget.showColorTip == true)
            HeatMapColorTip(
              colorMode: widget.colorMode,
              colorsets: widget.colorsets,
              leftWidget: widget.colorTipHelper?[0],
              rightWidget: widget.colorTipHelper?[1],
              containerCount: widget.colorTipCount,
              size: widget.colorTipSize,
            ),
        ],
      ),
    );
  }
}
