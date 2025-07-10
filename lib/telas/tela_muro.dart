import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TelaMuro extends StatefulWidget {
  @override
  State<TelaMuro> createState() => _TelaMuroState();
}

class _TelaMuroState extends State<TelaMuro> {
  TextEditingController alturaController = TextEditingController();
  TextEditingController larguraController = TextEditingController();
  String resultado = '';

  @override
  void initState() {
    super.initState();
    alturaController.text = '2.8'; // Altura padrão
  }

  void _calcular() {
    double altura = double.tryParse(alturaController.text.replaceAll(',', '.')) ?? 0;
    double largura = double.tryParse(larguraController.text.replaceAll(',', '.')) ?? 0;

    double area = altura * largura;
    int tijolos = (area * 57).round();
    double cimento = tijolos * 0.2;
    double areia = tijolos * 0.3;
    double ferragem = area * 0.1; // Exemplo
    double brita = area * 0.2; // Exemplo
    double canaletas = area * 0.05; // Exemplo

    setState(() {
      resultado = '''
Área: ${area.toStringAsFixed(2)} m²
Tijolos: $tijolos un
Cimento: ${cimento.toStringAsFixed(2)} sacos
Areia: ${areia.toStringAsFixed(2)} m³
Ferragem: ${ferragem.toStringAsFixed(2)} kg
Brita: ${brita.toStringAsFixed(2)} m³
Canaletas: ${canaletas.toStringAsFixed(2)} un
''';
    });
  }

  Future<void> _exportarPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Resultado:\n\n$resultado'),
          );
        },
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultado_muro.pdf');
    await file.writeAsBytes(await pdf.save());

    // Show a message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BlockCalc - Muro'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: alturaController,
                decoration: InputDecoration(labelText: 'Altura (m)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _calcular(),
              ),
              TextField(
                controller: larguraController,
                decoration: InputDecoration(labelText: 'Largura (m)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _calcular(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calcular,
                child: Text('Calcular'),
              ),
              SizedBox(height: 16),
              if (resultado.isNotEmpty) ...[
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(resultado, style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _exportarPDF,
                  child: Text('Exportar PDF'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
