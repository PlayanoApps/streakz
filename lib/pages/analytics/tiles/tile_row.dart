import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/analytics/tiles/small_tile.dart';

class TileRow extends StatelessWidget {
  final double gap;
  final SmallTile tile1;
  final SmallTile tile2;

  const TileRow({
    required this.gap,
    super.key,
    required this.tile1,
    required this.tile2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: tile1),
        SizedBox(width: gap),
        Expanded(child: tile2),
      ],
    );
  }
}
