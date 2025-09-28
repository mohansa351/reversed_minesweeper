import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/service/binance_ws_service.dart';
import '../domain/entities/board_tile.dart';
import '../domain/entities/board_piece.dart';


const int defaultRows = 10;
const int defaultCols = 10;
const int initialBombs = 10;
const int initialPieces = 20; 

class GameState {
  final int rows;
  final int cols;
  final Map<String, BoardTile> tiles; 
  final Map<String, BoardPiece> pieces; 
  final int discoveredBombs;
  final int explodedBombs;
  final bool running;
  final int totalBombs;

  GameState({
    required this.rows,
    required this.cols,
    required this.tiles,
    required this.pieces,
    required this.discoveredBombs,
    required this.explodedBombs,
    required this.running,
    required this.totalBombs,
  });

  int get bombsLeft => totalBombs - discoveredBombs - explodedBombs;

  GameState copyWith({
    int? rows,
    int? cols,
    Map<String, BoardTile>? tiles,
    Map<String, BoardPiece>? pieces,
    int? discoveredBombs,
    int? explodedBombs,
    bool? running,
    int? totalBombs,
  }) {
    return GameState(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      tiles: tiles ?? this.tiles,
      pieces: pieces ?? this.pieces,
      discoveredBombs: discoveredBombs ?? this.discoveredBombs,
      explodedBombs: explodedBombs ?? this.explodedBombs,
      running: running ?? this.running,
      totalBombs: totalBombs ?? this.totalBombs,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final BinanceWsService wsService;
  Timer? _explosionTimer;
  final Random _random = Random();

  GameNotifier({required this.wsService}) : super(_initialState()) {
    _startTimers();
    _listenBtcPrice();
  }

  static GameState _initialState({int rows = defaultRows, int cols = defaultCols}) {
    final tiles = <String, BoardTile>{};

    final r = Random();
    final totalCells = rows * cols;

    final List<int> indices = List.generate(totalCells, (i) => i);
    indices.shuffle(r);
    final bombCount = initialBombs;
    final bombs = indices.take(bombCount).toSet();

    final pieceCount = initialPieces.clamp(0, totalCells - bombCount);
    final piecePositions = indices.where((i) => !bombs.contains(i)).take(pieceCount).toList();


    for (int i = 0; i < totalCells; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final hasBomb = bombs.contains(i);
      tiles['$row:$col'] = BoardTile(row: row, col: col, hasBomb: hasBomb, state: hasBomb ? TileState.bombHidden : TileState.empty, pieceId: null);
    }

    final pieces = <String, BoardPiece>{};
    for (int i = 0; i < pieceCount; i++) {
      final piece = BoardPiece(label: 'P', originalRow: -1, originalCol: i);
      pieces[piece.id] = piece;
    }

    return GameState(
      rows: rows,
      cols: cols,
      tiles: tiles,
      pieces: pieces,
      discoveredBombs: 0,
      explodedBombs: 0,
      running: true,
      totalBombs: bombCount,
    );
  }

  void placePieceOnTile(String pieceId, int row, int col) {
    final key = '$row:$col';
    final tile = state.tiles[key];
    if (tile == null) return;

    if (tile.pieceId != null) {

      return;
    }

    final newTile = tile.copyWith(pieceId: pieceId, state: tile.hasBomb ? TileState.bombDiscovered : TileState.hasPiece);
    final newTiles = Map<String, BoardTile>.from(state.tiles);
    newTiles[key] = newTile;


    final newPieces = Map<String, BoardPiece>.from(state.pieces);
    newPieces.remove(pieceId);

    int discovered = state.discoveredBombs;
    int exploded = state.explodedBombs;

    if (tile.hasBomb) {
      discovered += 1;
    }

    state = state.copyWith(
      tiles: newTiles,
      pieces: newPieces,
      discoveredBombs: discovered,
      explodedBombs: exploded,
    );

    _checkGameOver();
  }

  void explodeRandomBomb() {
    final hiddenBombTiles = state.tiles.values.where((t) => t.hasBomb && t.state == TileState.bombHidden).toList();
    if (hiddenBombTiles.isEmpty) return;

    final tile = hiddenBombTiles[_random.nextInt(hiddenBombTiles.length)];
    final key = '${tile.row}:${tile.col}';
    final newTile = tile.copyWith(state: TileState.empty, 
    );

    final newTiles = Map<String, BoardTile>.from(state.tiles);
    newTiles[key] = newTile.copyWith(hasBomb: false);

    state = state.copyWith(
      tiles: newTiles,
      explodedBombs: state.explodedBombs + 1,
    );

    _checkGameOver();
  }

  void _checkGameOver() {
    if (state.bombsLeft <= 0) {
      _explosionTimer?.cancel();
      state = state.copyWith(running: false);
    }
  }

  void _startTimers() {
    _explosionTimer?.cancel();
    _explosionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      explodeRandomBomb();
    });
  }

  void _listenBtcPrice() {

    wsService.stream.listen((event) {

      final intPrice = wsService.latestBtcIntPrice;
      if (intPrice == null) return;

      if (intPrice % 5 == 0) {
        final currentBombCount = state.totalBombs;
        final totalCells = state.rows * state.cols;
        final maxBombs = (totalCells / 2).floor(); 
        if (state.totalBombs < maxBombs) {

          final emptyTiles = state.tiles.values.where((t) => !t.hasBomb && t.pieceId == null).toList();
          if (emptyTiles.isNotEmpty) {
            final sel = emptyTiles[_random.nextInt(emptyTiles.length)];
            final key = '${sel.row}:${sel.col}';
            final newTiles = Map<String, BoardTile>.from(state.tiles);
            newTiles[key] = sel.copyWith(hasBomb: true, state: TileState.bombHidden);
            state = state.copyWith(tiles: newTiles, totalBombs: state.totalBombs + 1);
          }
        }
      }
    });
  }


  void resetGame() {
    _explosionTimer?.cancel();
    final newState = _initialState(rows: state.rows, cols: state.cols);
    state = newState;
    _startTimers();
  }

  @override
  void dispose() {
    _explosionTimer?.cancel();
    wsService.dispose();
    super.dispose();
  }
}

final binanceWsServiceProvider = Provider<BinanceWsService>((ref) {
  return BinanceWsService(mockMode: true);
});

final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final ws = ref.read(binanceWsServiceProvider);
  return GameNotifier(wsService: ws);
});
