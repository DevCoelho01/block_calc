import 'package:flutter/material.dart';
import 'telas/tela_home.dart';
import 'telas/tela_muro.dart';
import 'telas/tela_comodo.dart';
import 'telas/tela_casa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockCalc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaHome(),
        '/muro': (context) => TelaMuro(),
        '/comodo': (context) => TelaComodo(),
        '/casa': (context) => TelaCasa(),
      },
    );
  }
}
