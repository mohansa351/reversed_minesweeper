import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceWsService {
  final bool mockMode;
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();
  Stream<Map<String, dynamic>> get stream => _controller.stream;
  int? latestBtcIntPrice;
  Timer? _mockTimer;
  final Random _r = Random();

  BinanceWsService({this.mockMode = false}) {
    if (mockMode) {
      _startMock();
    } else {
      
    }
  }

  void _startMock() {
    _mockTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final price = 20000 + _r.nextInt(1000); 
      latestBtcIntPrice = price;
      _controller.add({'mock_price': price});
    });
  }

  void dispose() {
    _mockTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}
