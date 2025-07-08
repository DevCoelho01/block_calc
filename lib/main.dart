import 'package:flutter/material.dart';

// Importe suas telas:
import 'telas/tela_home.dart';
import 'telas/tela_muro.dart';
import 'telas/tela_comodo.dart';
import 'telas/tela_casa.dart';
// ignore: unused_import
import 'telas/tela_resultado.dart';

void main() {
  runApp(const BlockCalcApp());
}

class BlockCalcApp extends StatelessWidget {
  const BlockCalcApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove a faixa de debug
      title: 'Block Calc',
      theme: ThemeData(
        useMaterial3: true, // Material 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
