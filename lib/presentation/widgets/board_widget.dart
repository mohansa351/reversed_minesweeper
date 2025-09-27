import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_tile.dart';
import '../provider/game_providers.dart';
import 'piece_widget.dart';
import 'tile_widget.dart';

class BoardWidget extends ConsumerWidget {
  final double tileSize;

  const BoardWidget({super.key, this.tileSize = 48});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);

    final rows = game.rows;
    final cols = game.cols;

    final pieces = game.pieces.values.toList();

    return Column(
      children: [
        SizedBox(
          height: tileSize + 12,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: pieces.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: LongPressDraggable<String>(
                  data: p.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: PieceWidget(label: p.label, size: tileSize),
                  ),
                  childWhenDragging: Opacity(
                      opacity: 0.4,
                      child: PieceWidget(label: p.label, size: tileSize)),
                  child: PieceWidget(label: p.label, size: tileSize),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        Column(
          children: List.generate(rows, (r) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (c) {
                final key = '$r:$c';
                final tile = game.tiles[key]!;

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) => tile.pieceId == null,
                    onAcceptWithDetails: (details) {
                      notifier.placePieceOnTile(details.data, r, c);
                    },
                    builder: (context, candidateData, rejectedData) {
                      Widget inside = const SizedBox.shrink();
                      if (tile.pieceId != null) {
                        inside = PieceWidget(label: 'P', size: tileSize - 8);
                      } else if (tile.state == TileState.bombDiscovered) {
                        inside =
                            Icon(Icons.bug_report, color: Colors.red, size: 20);
                      }

                      return TileWidget(
                          tile: tile, size: tileSize, child: inside);
                    },
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}
