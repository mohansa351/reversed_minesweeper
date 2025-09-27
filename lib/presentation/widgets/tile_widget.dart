import 'package:flutter/material.dart';
import '../../domain/entities/board_tile.dart';

class TileWidget extends StatelessWidget {
  final BoardTile tile;
  final double size;
  final Widget? child;

  const TileWidget({super.key, required this.tile, this.size = 48, this.child});

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (tile.state == TileState.bombDiscovered) {
      bg = Colors.redAccent;
    } else if (tile.state == TileState.bombHidden) {
      bg = Colors.grey.shade300;
    } else {
      bg = Colors.green.shade50;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
