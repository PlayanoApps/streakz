import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/components/general/custom_dialog.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void showThemeDialog(context) {
  HapticFeedback.lightImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder:
        (context, x, y) => AlertDialog(
          title: Text(
            "Select Color",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          content: StatefulBuilder(
            builder:
                (context, StateSetter setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    radioTile(value: 1, text: "Mint (default)"),
                    Divider(color: Theme.of(context).colorScheme.primary),
                    radioTile(value: 2, text: "Azure blue"),
                    radioTile(value: 3, text: "Vibrant red"),
                    radioTile(value: 4, text: "Magenta pink"),
                    Divider(color: Theme.of(context).colorScheme.primary),
                    radioTile(value: 5, text: "Monochrome 1"),
                    radioTile(value: 6, text: "Monochrome 2"),
                    radioTile(value: 7, text: "Experimental"),
                  ],
                ),
          ),
        ),
    transitionDuration: Duration(milliseconds: 300),
    transitionBuilder: moveUpTransition(),
  );
}

Widget radioTile({required int value, required String text}) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return InkWell(
        onTap: () => themeProvider.setAccentColor(value),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Radio(
              value: value,
              groupValue: themeProvider.selectedColor,
              onChanged: (val) {
                if (val != null) themeProvider.setAccentColor(val);
              },
            ),
            Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      );
    },
  );
}
