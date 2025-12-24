import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onLongPress;
  final String text;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20), // 25
      child: Material(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.grey.withAlpha(70),
          highlightColor: Colors.grey.withAlpha(80),
          splashFactory: InkSparkle.splashFactory,

          // Container
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                width: 1,
                color:
                    darkMode
                        ? Colors.grey.withAlpha(30)
                        : Colors.white.withAlpha(100),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 13, // 13
                bottom: 13,
                left: 15,
                right: 5,
              ), // 15
              // List Tile
              child: ListTile(
                title: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // 16
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                trailing: trailing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* Widget _settingsTile({
  required void Function()? onTap,
  required void Function()? onLongPress,
  required String text,
  Widget? trailing,
}) {
  bool darkMode = (Theme.of(context).brightness == Brightness.dark);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25), // 5.5
    child: Material(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.grey.withAlpha(70),
        highlightColor: Colors.grey.withAlpha(80),
        splashFactory: InkSparkle.splashFactory,

        // Container
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 1,
              color:
                  darkMode
                      ? Colors.grey.withAlpha(30)
                      : Colors.white.withAlpha(100),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 13,
              bottom: 13,
              left: 15,
              right: 5,
            ), // 15
            // List Tile
            child: ListTile(
              title: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              trailing: trailing,
            ),
          ),
        ),
      ),
    ),
  );
}
 */
