import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // <-- ESSE É O IMPORT QUE FALTAVA!
import 'package:printing/printing.dart';
class TelaMuro extends StatefulWidget {
  @override
  State<TelaMuro> createState() => _TelaMuroState();
}

class _TelaMuroState extends State<TelaMuro> {
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _comprimentoController = TextEditingController();
  bool temJanela = false;
  int numeroJanelas = 0;

  List<TextEditingController> alturaJanelas = [];
  List<TextEditingController> larguraJanelas = [];

  String resultado = '';

  void _atualizarNumeroJanelas(int valor) {
    setState(() {
      numeroJanelas = valor;
      alturaJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
      larguraJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
    });
  }

  void _calcular() {
    double altura = double.tryParse(_alturaController.text.replaceAll(',', '.')) ?? 0;
    double comprimento = double.tryParse(_comprimentoController.text.replaceAll(',', '.')) ?? 0;

    double areaMuro = altura * comprimento;

    double areaJanelas = 0;
    for (int i = 0; i < numeroJanelas; i++) {
      double alturaJ = double.tryParse(alturaJanelas[i].text.replaceAll(',', '.')) ?? 0;
      double larguraJ = double.tryParse(larguraJanelas[i].text.replaceAll(',', '.')) ?? 0;
      areaJanelas += alturaJ * larguraJ;
    }

    double areaUtil = areaMuro - areaJanelas;

    int tijolos = (areaUtil * 57).round();
    double cimento = tijolos * 0.2;
    double areia = tijolos * 0.3;
    double ferragem = areaUtil * 0.1; // Exemplo
    double brita = areaUtil * 0.2;    // Exemplo novo
    double canaletas = areaUtil * 0.05; // Exemplo

    setState(() {
      resultado = '''
Área Util: ${areaUtil.toStringAsFixed(2)} m²
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
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
                controller: _alturaController,
                decoration: InputDecoration(labelText: 'Altura do muro (m)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _calcular(),
              ),
              TextField(
                controller: _comprimentoController,
                decoration: InputDecoration(labelText: 'Comprimento do muro (m)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _calcular(),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Tem janela?'),
                  Switch(
                    value: temJanela,
                    onChanged: (val) {
                      setState(() {
                        temJanela = val;
                        if (!temJanela) {
                          numeroJanelas = 0;
                          alturaJanelas.clear();
                          larguraJanelas.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              if (temJanela) ...[
                TextField(
                  decoration: InputDecoration(labelText: 'Quantas janelas?'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    int val = int.tryParse(value) ?? 0;
                    _atualizarNumeroJanelas(val);
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numeroJanelas,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text('Janela ${index + 1}'),
                            TextField(
                              controller: alturaJanelas[index],
                              decoration: InputDecoration(labelText: 'Altura (m)'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onSubmitted: (_) => _calcular(),
                            ),
                            TextField(
                              controller: larguraJanelas[index],
                              decoration: InputDecoration(labelText: 'Largura (m)'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              onSubmitted: (_) => _calcular(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calcular,
                child: Text('Calcular'),
              ),
              SizedBox(height: 16),
              if (resultado.isNotEmpty) ...[
                Card(
                  color: Colors.blue.shade50,
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
