import 'package:flutter/material.dart';

class PieceWidget extends StatelessWidget {
  final String label;
  final double size;

  const PieceWidget({super.key, required this.label, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 76, 211, 189),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.15 * 255).toInt()),
            blurRadius: 6,
          )
        ],
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
