import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Skeleton AppBar
    PreferredSizeWidget buildSkeletonAppBar() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(isDark ? 0.9 : 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Center(
          child: Container(
            height: 22,
            width: 120,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(isDark ? 0.9 : 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(12),
            width: 33,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(isDark ? 0.9 : 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      );
    }

    // Skeleton Heatmap
    Widget buildSkeletonHeatmap() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: EdgeInsets.only(left: 22, right: 22, top: 25, bottom: 15),
        child: Container(
          height: 270,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0 : 0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heatmap title placeholder
                Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.4 : 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(width: 35),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.4 : 0.6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    SizedBox(width: 35),
                    Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.4 : 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17),
                // Grid placeholder
                Expanded(
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                    ),
                    itemCount: 22,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.4 : 0.5),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Skeleton Habit List
    Widget buildSkeletonHabitList() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25), // Wie in HabitTile
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6), // Wie in HabitTile
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isDark ? 0.4 : 0.6),
                border: Border.all(
                  width: 0.9,
                  color: Colors.white.withOpacity(isDark ? 0.5 : 1),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.only(top: 24, bottom: 24),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary
                                  .withOpacity(isDark ? 0.2 : 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          SizedBox(width: 35),
                          // Text
                          Expanded(
                            child: Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary
                                    .withOpacity(isDark ? 0.2 : 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    // Arrow button
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(isDark ? 0.2 : 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Skeleton Body mit Shimmer
    Widget buildSkeletonScreen(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final baseColor =
          isDark ? Colors.grey[800]! : Colors.grey[200]!.withOpacity(1);
      final highlightColor = isDark ? Colors.grey[700]! : Colors.white;

      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,

        child: Column(
          children: [
            // Divider
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Divider(
                color: Theme.of(context).colorScheme.secondary,
                height: 5,
              ),
            ),

            // Skeleton Heatmap
            buildSkeletonHeatmap(),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    physics: BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 0),

                      // Skeleton Habit List
                      buildSkeletonHabitList(),

                      SizedBox(height: 30),
                    ],
                  ),
                  //MyGradient(top: true, height: 30),
                  //MyGradient(height: 30),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: buildSkeletonAppBar(),
      body: buildSkeletonScreen(context),
    );
  }
}
