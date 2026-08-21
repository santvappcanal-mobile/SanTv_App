import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/canales_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SanTvApp());
}

class SanTvApp extends StatelessWidget {
  const SanTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CanalesProvider(),
      child: MaterialApp(
        title: 'SanTv',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}