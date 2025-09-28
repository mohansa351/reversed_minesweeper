import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../domain/entities/board_tile.dart';
import 'dart:math';

class TileWidget extends StatefulWidget {
  final BoardTile tile;
  final double size;
  final Widget? child;

  const TileWidget({
    super.key,
    required this.tile,
    this.size = 48,
    this.child,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _player = AudioPlayer();
  final random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.state == TileState.bombDiscovered &&
        oldWidget.tile.state != TileState.bombDiscovered) {
      _controller.forward(from: 0);
      _player.play(AssetSource('sounds/explosion.mp3'));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final curve = Curves.easeOutExpo.transform(t);

          final shockwaveSize = widget.size * (1 + curve * 3);
          final shockwaveOpacity = (1 - curve).clamp(0.0, 1.0);

          final flashOpacity = (t < 0.15) ? (1 - t / 0.15) : 0.0;

          final scale = 1 + sin(t * pi) * 0.25;

          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.tile.state == TileState.bombDiscovered)
                Container(
                  width: shockwaveSize,
                  height: shockwaveSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orangeAccent
                          .withAlpha((0.5 * shockwaveOpacity * 255).toInt())),
                ),

              if (widget.tile.state == TileState.bombDiscovered)
                Opacity(
                  opacity: flashOpacity,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(widget.size * 0.3),
                    ),
                  ),
                ),

              Transform.scale(
                scale:
                    (widget.tile.state == TileState.bombDiscovered) ? scale : 1,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.tile.state == TileState.bombDiscovered
                        ? Colors.grey
                        : (widget.tile.state == TileState.bombHidden
                            ? Colors.grey.shade300
                            : Colors.green.shade50),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                    boxShadow: [
                      if (widget.tile.state == TileState.bombDiscovered)
                        BoxShadow(
                          color: Colors.white
                              .withAlpha((0.6 * (1 - t) * 255).toInt()),
                          blurRadius: 20 * (1 - t),
                          spreadRadius: 6 * (1 - t),
                        ),
                    ],
                  ),
                  child: widget.child ?? const SizedBox.shrink(),
                ),
              ),

              if (widget.tile.state == TileState.bombDiscovered)
                ...List.generate(8, (i) {
                  final angle = i * (pi / 4) + t * pi;
                  final distance =
                      curve * widget.size * (1.5 + random.nextDouble());
                  final sizeP = 6 + random.nextDouble() * 4;
                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * distance,
                      sin(angle) * distance,
                    ),
                    child: Opacity(
                      opacity: (1 - t),
                      child: Container(
                        width: sizeP * (1 - t),
                        height: sizeP * (1 - t),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                  );
                }),

              if (widget.tile.state == TileState.bombDiscovered)
                ...List.generate(12, (i) {
                  final angle = i * (pi / 6) - t * pi;
                  final distance =
                      curve * widget.size * (0.5 + random.nextDouble() * 2);
                  final sizeP = 3 + random.nextDouble() * 3;
                  return Transform.translate(
                    offset: Offset(
                      cos(angle) * distance,
                      sin(angle) * distance,
                    ),
                    child: Opacity(
                      opacity: (1 - t),
                      child: Container(
                        width: sizeP * (1 - t),
                        height: sizeP * (1 - t),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
