import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature/game/presentation/pages/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reversed Minesweeper",
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: Consumer(
        builder: (context, ref, _) {
          return GamePage();
        },
      ),
    );
  }
}
