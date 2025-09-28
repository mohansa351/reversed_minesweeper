# reversed_minesweeper_poc

# Reversed Minesweeper — Flutter Challenge (Riverpod + Clean-ish architecture)

## Overview
This project implements a reversed minesweeper game where the player places pieces onto a 10x10 board and discovers hidden bombs. A timer explodes bombs every 10 seconds. The app also connects to Binance websocket and adds bombs when integer BTC price divisible by 5.

## How to run
1. Ensure Flutter SDK is installed.
2. Clone repository.
3. `flutter pub get`
4. `flutter run` (or open in IDE)

Note: WebSocket uses a `mockMode` by default to avoid needing live connection during development. To use real Binance feed, change `mockMode: false` in `binance_ws_service.dart`.

## Architecture
- `domain/` contains entities.
- `presentation/providers/` contains Riverpod state notifiers.
- `presentation/widgets/` contains UI pieces.
- `core/ws/` holds Binance WS wrapper.

## Features implemented
- 10x10 board
- Drag & drop with `LongPressDraggable` and `DragTarget`
- Bomb discovery (drop on bomb increases discovered count)
- Periodic explosion timer (10s)
- Binance WS integration (mocked by default)
- Game over detection (when all bombs discovered or exploded)
- Basic animations & visual feedback

## Notes & next steps
Recommended improvements:
- Add nicer animations (explosion, piece slide).
- Add x/y coordinate mapping and better UI for piece pool.

