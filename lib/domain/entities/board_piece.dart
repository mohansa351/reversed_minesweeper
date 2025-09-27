import 'package:uuid/uuid.dart';

class BoardPiece {
  final String id;
  final String label;
  final int originalRow;
  final int originalCol;

  BoardPiece({
    String? id,
    required this.label,
    required this.originalRow,
    required this.originalCol,
  }) : id = id ?? const Uuid().v4();

  BoardPiece copyWith({
    String? id,
    String? label,
    int? originalRow,
    int? originalCol,
  }) {
    return BoardPiece(
      id: id ?? this.id,
      label: label ?? this.label,
      originalRow: originalRow ?? this.originalRow,
      originalCol: originalCol ?? this.originalCol,
    );
  }
}
