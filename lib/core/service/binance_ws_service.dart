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
      _connect();
    }
  }

  void _startMock() {
    _mockTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final price = 20000 + _r.nextInt(1000); 
      latestBtcIntPrice = price;
      _controller.add({'mock_price': price});
    });
  }

  Future<void> _connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('wss://stream.binance.com:9443/ws'));
      final payload = jsonEncode({
        "method": "SUBSCRIBE",
        "params": ["btcusdt@ticker"],
        "id": 1
      });
      _channel!.sink.add(payload);

      _channel!.stream.listen((dynamic msg) {
        try {
          final data = jsonDecode(msg as String) as Map<String, dynamic>;
          if (data.containsKey('c')) {
            final priceStr = (data['c'] ?? '').toString();
            final intPrice = int.tryParse(priceStr.split('.').first);
            if (intPrice != null) {
              latestBtcIntPrice = intPrice;
              _controller.add(data);
            }
          } else {
            _controller.add(data);
          }
        } catch (e) {
          _controller.add({'raw': msg});
        }
      }, onError: (e) {
        _controller.add({'error': e.toString()});
      }, onDone: () {

        Future.delayed(const Duration(seconds: 3), () => _connect());
      });
    } catch (e) {
      _controller.add({'error': e.toString()});
      Future.delayed(const Duration(seconds: 3), () => _connect());
    }
  }

  void dispose() {
    _mockTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}
