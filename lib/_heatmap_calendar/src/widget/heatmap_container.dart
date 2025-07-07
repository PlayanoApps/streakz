import 'package:flutter/material.dart';
import '../data/heatmap_color.dart';

class HeatMapContainer extends StatelessWidget {
  final DateTime date;
  final double? size;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? highlightedBorderColor;
  final double? highlightedBorderWith;
  final Color? selectedColor;
  final Color? textColor;
  final EdgeInsets? margin;
  final bool? showText;
  final Function(DateTime dateTime)? onClick;

  const HeatMapContainer({
    super.key,
    required this.date,
    this.margin,
    this.size,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.highlightedBorderColor,
    this.highlightedBorderWith,
    this.selectedColor,
    this.textColor,
    this.onClick,
    this.showText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () async {
            await Future.delayed(const Duration(microseconds: 50));
            if (onClick != null) onClick!(date);
          },
          borderRadius: BorderRadius.circular(borderRadius ?? 5),
          highlightColor: Colors.grey.withAlpha(70),
          splashColor: Colors.grey.withAlpha(40),
          child: Ink(
            decoration: BoxDecoration(
              color: selectedColor ?? backgroundColor ?? HeatMapColor.defaultColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 5),

              // Background color highlight is determined in heatmap_calendar_row
              // BORDER HIGHLIGHT
              border: Border.all(
                color: highlightedBorderColor ?? Colors.transparent,
                width: highlightedBorderWith!,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutQuad,
              width: size,
              height: size,
              alignment: Alignment.center,
              child: (showText ?? true)
                  ? Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: textColor ?? const Color(0xFF8A8A8A),
                        fontSize: fontSize,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
