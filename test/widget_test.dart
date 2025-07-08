import 'package:flutter/material.dart';

void main() {
  runApp(const BlockCalcApp());
}

class BlockCalcApp extends StatelessWidget {
  const BlockCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Calc',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const BlockCalcHome(),
    );
  }
}

class BlockCalcHome extends StatefulWidget {
  const BlockCalcHome({super.key});

  @override
  State<BlockCalcHome> createState() => _BlockCalcHomeState();
}

class _BlockCalcHomeState extends State<BlockCalcHome> {
  final TextEditingController _tijolosController = TextEditingController();
  double cimento = 0;
  double areia = 0;

  void calcular() {
    final tijolos = double.tryParse(_tijolosController.text) ?? 0;
    setState(() {
      cimento = tijolos * 0.2;
      areia = tijolos * 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Calc - Tijolos Ecológicos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tijolosController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de Tijolos',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calcular,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 20),
            Text('Cimento necessário: ${cimento.toStringAsFixed(2)} sacos'),
            Text('Areia necessária: ${areia.toStringAsFixed(2)} m³'),
          ],
        ),
      ),
    );
  }
}
