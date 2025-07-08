import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  // Função para atualizar a lista de controladores
  void _atualizarComodos(int qtd) {
    setState(() {
      numeroComodos = qtd;
      larguraControllers = List.generate(qtd, (_) => TextEditingController());
      comprimentoControllers =
          List.generate(qtd, (_) => TextEditingController());
      if (!peDireitoIgual) {
        peDireitoControllers =
            List.generate(qtd, (_) => TextEditingController());
      } else {
        peDireitoControllers.clear();
      }
    });
  }

  void _calcular() {
    double areaTotal = 0;
    double perimetroTotal = 0;

    for (int i = 0; i < numeroComodos; i++) {
      double largura =
          double.tryParse(larguraControllers[i].text.replaceAll(',', '.')) ?? 0;
      double comprimento = double.tryParse(
              comprimentoControllers[i].text.replaceAll(',', '.')) ??
          0;
      double altura = peDireitoIgual
          ? peDireito
          : (double.tryParse(
                  peDireitoControllers[i].text.replaceAll(',', '.')) ??
              peDireito);

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
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
              // Quantidade de cômodos
              TextField(
                decoration: InputDecoration(labelText: 'Quantos cômodos?'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  int qtd = int.tryParse(val) ?? 0;
                  _atualizarComodos(qtd);
                },
              ),

              SizedBox(height: 8),

              // Pé-direito igual para todos?
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
                        } else {
                          peDireitoControllers = List.generate(
                              numeroComodos, (_) => TextEditingController());
                        }
                      });
                    },
                  ),
                ],
              ),

              if (peDireitoIgual)
                TextField(
                  decoration: InputDecoration(labelText: 'Pé-direito (m)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    peDireito =
                        double.tryParse(val.replaceAll(',', '.')) ?? 2.8;
                  },
                ),

              SizedBox(height: 8),

              // Telhado e piso
              DropdownButton<String>(
                value: tipoTelhado,
                items: ['Barro', 'Sanduíche']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    tipoTelhado = val!;
                  });
                },
              ),
              DropdownButton<String>(
                value: tipoPiso,
                items: ['Cerâmica', 'Porcelanato']
                    .map((e) => DropdownMenuItem(child: Text(e), value: e))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    tipoPiso = val!;
                  });
                },
              ),

              SizedBox(height: 16),

              // Campos de cada cômodo
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: numeroComodos,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cômodo ${index + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextField(
                            controller: larguraControllers[index],
                            decoration:
                                InputDecoration(labelText: 'Largura (m)'),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            onSubmitted: (_) => _calcular(),
                          ),
                          TextField(
                            controller: comprimentoControllers[index],
                            decoration:
                                InputDecoration(labelText: 'Comprimento (m)'),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            onSubmitted: (_) => _calcular(),
                          ),
                          if (!peDireitoIgual)
                            TextField(
                              controller: peDireitoControllers[index],
                              decoration:
                                  InputDecoration(labelText: 'Pé-direito (m)'),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              onSubmitted: (_) => _calcular(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
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
