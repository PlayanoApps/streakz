import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallTile extends StatelessWidget {
  final String title, text, subtext;

  const SmallTile({
    super.key,
    required this.title,
    required this.text,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withOpacity(darkMode ? 0.8 : 1),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 0),
            Text(
              subtext,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(darkMode ? 1 : 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
