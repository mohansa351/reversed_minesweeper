import 'package:uuid/uuid.dart';

enum TileState { empty, hasPiece, bombHidden, bombDiscovered }

class BoardTile {
  final String id;
  final int row;
  final int col;
  final bool hasBomb;
  final String? pieceId; 
  final TileState state;

  BoardTile({
    String? id,
    required this.row,
    required this.col,
    required this.hasBomb,
    this.pieceId,
    required this.state,
  }) : id = id ?? const Uuid().v4();

  BoardTile copyWith({
    String? id,
    int? row,
    int? col,
    bool? hasBomb,
    String? pieceId,
    TileState? state,
  }) {
    return BoardTile(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      hasBomb: hasBomb ?? this.hasBomb,
      pieceId: pieceId ?? this.pieceId,
      state: state ?? this.state,
    );
  }
}
