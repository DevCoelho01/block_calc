import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TelaCasa extends StatefulWidget {
  @override
  State<TelaCasa> createState() => _TelaCasaState();
}

class _TelaCasaState extends State<TelaCasa> {
  int numeroComodos = 0;
  bool peDireitoIgual = true;
  double peDireito = 2.8; // padrão
  String tipoTelhado = 'Barro';
  String tipoPiso = 'Cerâmica';

  List<TextEditingController> larguraControllers = [];
  List<TextEditingController> comprimentoControllers = [];
  List<TextEditingController> peDireitoControllers = [];

  String resultado = '';

  void _atualizarComodos(int qtd) {
    setState(() {
      numeroComodos = qtd;
      larguraControllers = List.generate(qtd, (_) => TextEditingController());
      comprimentoControllers = List.generate(qtd, (_) => TextEditingController());
      if (!peDireitoIgual) {
        peDireitoControllers = List.generate(qtd, (_) => TextEditingController());
      } else {
        peDireitoControllers.clear();
      }
    });
  }

  void _calcular() {
    double areaTotal = 0;
    double perimetroTotal = 0;

    for (int i = 0; i < numeroComodos; i++) {
      double largura = double.tryParse(larguraControllers[i].text.replaceAll(',', '.')) ?? 0;
      double comprimento = double.tryParse(comprimentoControllers[i].text.replaceAll(',', '.')) ?? 0;
      double altura = peDireitoIgual
          ? peDireito
          : (double.tryParse(peDireitoControllers[i].text.replaceAll(',', '.')) ?? peDireito);

      areaTotal += largura * comprimento;
      perimetroTotal += 2 * (largura + comprimento) * altura;
    }

    double areaParedes = perimetroTotal;

    int tijolos = (areaParedes * 57).round();
    double cimento = tijolos * 0.2;
    double areia = tijolos * 0.3;
    double graute = areaParedes * 0.1; // Exemplo
    double vigas = areaParedes * 0.05; // Exemplo

    double piso = areaTotal * 1.05; // 5% de margem de perda
    double telhado = areaTotal * 1.2; // inclinação média

    setState(() {
      resultado = '''
Área total: ${areaTotal.toStringAsFixed(2)} m²
Área de Paredes: ${areaParedes.toStringAsFixed(2)} m²

Tijolos: $tijolos un
Cimento: ${cimento.toStringAsFixed(2)} sacos
Areia: ${areia.toStringAsFixed(2)} m³
Graute: ${graute.toStringAsFixed(2)} m³
Vigas: ${vigas.toStringAsFixed(2)} m³

Piso (${tipoPiso}): ${piso.toStringAsFixed(2)} m²
Telhado (${tipoTelhado}): ${telhado.toStringAsFixed(2)} m²
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
    final file = File('${output.path}/resultado_casa.pdf');
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
        title: Text('BlockCalc - Casa'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número de cômodos
              TextField(
                decoration: InputDecoration(labelText: 'Quantos cômodos?'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int val = int.tryParse(value) ?? 0;
                  _atualizarComodos(val);
                },
              ),
              
              // Pé-direito
              Row(
                children: [
                  Text('Pé-direito igual?'),
                  Switch(
                    value: peDireitoIgual,
                    onChanged: (val) {
                      setState(() {
                        peDireitoIgual = val;
                        if (peDireitoIgual) {
                          peDireitoControllers.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              
              if (!peDireitoIgual) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numeroComodos,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text('Pé-direito Cômodo ${index + 1}'),
                            TextField(
                              controller: peDireitoControllers[index],
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: 'Altura (m)'),
                              onSubmitted: (_) => _calcular(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              
              // Campos dos cômodos
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: numeroComodos,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text('Cômodo ${index + 1}'),
                          TextField(
                            controller: larguraControllers[index],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Largura (m)'),
                            onSubmitted: (_) => _calcular(),
                          ),
                          TextField(
                            controller: comprimentoControllers[index],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Comprimento (m)'),
                            onSubmitted: (_) => _calcular(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Tipos de material
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tipoTelhado,
                      decoration: InputDecoration(labelText: 'Tipo de Telhado'),
                      items: ['Barro', 'Metal', 'Fibrocimento'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoTelhado = newValue!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: tipoPiso,
                      decoration: InputDecoration(labelText: 'Tipo de Piso'),
                      items: ['Cerâmica', 'Porcelanato', 'Laminado'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tipoPiso = newValue!;
                        });
                      },
                    ),
                  ),
                ],
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
