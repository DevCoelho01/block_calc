import 'package:flutter/material.dart';

class TelaResultado extends StatelessWidget {
  final String titulo;
  final String resultado;

  const TelaResultado({
    Key? key,
    required this.titulo,
    required this.resultado,
  }) : super(key: key);

  List<Widget> _formatarResultado() {
    return resultado
        .trim()
        .split('\n')
        .map((linha) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    linha.split(':')[0],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  SizedBox(width: 10),
                  Text(
                    linha.split(':').length > 1
                        ? linha.split(':')[1].trim()
                        : '',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhes do cálculo:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(thickness: 1),
                ..._formatarResultado(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
