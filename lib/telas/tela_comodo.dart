import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TelaComodo extends StatefulWidget {
  @override
  State<TelaComodo> createState() => _TelaComodoState();
}

class _TelaComodoState extends State<TelaComodo> {
  int numeroParedes = 1;
  bool paredesIguais = true;
  bool temJanela = false;
  int numeroJanelas = 0;

  List<TextEditingController> alturaParedes = [];
  List<TextEditingController> larguraParedes = [];
  List<TextEditingController> alturaJanelas = [];
  List<TextEditingController> larguraJanelas = [];

  String resultado = '';

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    alturaParedes = List.generate(numeroParedes, (_) => TextEditingController());
    larguraParedes = List.generate(numeroParedes, (_) => TextEditingController());
    alturaJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
    larguraJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
  }

  void _atualizarNumeroParedes(int valor) {
    setState(() {
      numeroParedes = valor;
      _inicializarControladores();
    });
  }

  void _atualizarNumeroJanelas(int valor) {
    setState(() {
      numeroJanelas = valor;
      alturaJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
      larguraJanelas = List.generate(numeroJanelas, (_) => TextEditingController());
    });
  }

  void _calcular() {
    double areaTotal = 0;

    for (int i = 0; i < numeroParedes; i++) {
      double altura = double.tryParse(alturaParedes[i].text.replaceAll(',', '.')) ?? 0;
      double largura = double.tryParse(larguraParedes[i].text.replaceAll(',', '.')) ?? 0;
      areaTotal += altura * largura;
    }

    double areaJanelas = 0;
    for (int i = 0; i < numeroJanelas; i++) {
      double altura = double.tryParse(alturaJanelas[i].text.replaceAll(',', '.')) ?? 0;
      double largura = double.tryParse(larguraJanelas[i].text.replaceAll(',', '.')) ?? 0;
      areaJanelas += altura * largura;
    }

    double areaUtil = areaTotal - areaJanelas;

    int tijolos = (areaUtil * 57).round();
    double cimento = tijolos * 0.2;
    double areia = tijolos * 0.3;
    double ferragem = areaUtil * 0.1; // Exemplo
    double brita = areaUtil * 0.2; // Exemplo
    double canaletas = areaUtil * 0.05; // Exemplo

    setState(() {
      resultado = '''
Área Total: ${areaUtil.toStringAsFixed(2)} m²
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
    final file = File('${output.path}/resultado_comodo.pdf');
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
        title: Text('BlockCalc - Cômodo'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Quantas paredes?'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int val = int.tryParse(value) ?? 1;
                  _atualizarNumeroParedes(val);
                },
              ),
              Row(
                children: [
                  Text('Paredes iguais?'),
                  Switch(
                    value: paredesIguais,
                    onChanged: (val) {
                      setState(() {
                        paredesIguais = val;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: paredesIguais ? 1 : numeroParedes,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text('Parede ${index + 1}'),
                          TextField(
                            controller: alturaParedes[index],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Altura (m)'),
                            onSubmitted: (_) => _calcular(),
                          ),
                          TextField(
                            controller: larguraParedes[index],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Largura (m)'),
                            onSubmitted: (_) => _calcular(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: 'Altura (m)'),
                              onSubmitted: (_) => _calcular(),
                            ),
                            TextField(
                              controller: larguraJanelas[index],
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: 'Largura (m)'),
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
