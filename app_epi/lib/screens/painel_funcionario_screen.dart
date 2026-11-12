import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/emprestimo_service.dart';
import '../services/treinamento_service.dart';
import '../widgets/indicador_card.dart';
import 'meus_emprestimos_screen.dart';
import 'treinamentos_screen.dart';

// Exercício 3: painel do funcionário.
// Também não tem Scaffold: aparece dentro do body da MainScreen.
// Reaproveita o IndicadorCard e os services já existentes.
class PainelFuncionario extends StatefulWidget {
  final Usuario usuario;

  const PainelFuncionario({
    super.key,
    required this.usuario,
  });

  @override
  State<PainelFuncionario> createState() => _PainelFuncionarioState();
}

class _PainelFuncionarioState extends State<PainelFuncionario> {
  // [0] = EPIs em uso, [1] = treinamentos pendentes
  late Future<List<int>> futuroContadores;
  DateTime atualizadoEm = DateTime.now();

  @override
  void initState() {
    super.initState();
    futuroContadores = carregarContadores();
  }

  Future<List<int>> carregarContadores() async {
    final emprestimoService = EmprestimoService();
    final treinamentoService = TreinamentoService();

    final emprestimos = await emprestimoService.buscarPorFuncionario(
      widget.usuario.id,
    );
    final treinamentos = await treinamentoService.buscarTreinamentos();
    final realizados = await treinamentoService.buscarRealizados(
      widget.usuario.id,
    );

    final emUso = emprestimos.where((e) => e.status == 'EMPRESTADO').length;
    final pendentes = treinamentos.length - realizados.length;

    return [emUso, pendentes < 0 ? 0 : pendentes];
  }

  Future<void> recarregar() async {
    setState(() {
      futuroContadores = carregarContadores();
      atualizadoEm = DateTime.now();
    });
    await futuroContadores;
  }

  // Abre outra tela e, ao voltar, atualiza os números
  void abrir(Widget tela) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tela),
    ).then((_) => recarregar());
  }

  String doisDigitos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: futuroContadores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            ),
          );
        }

        final contadores = snapshot.data!;

        return RefreshIndicator(
          onRefresh: recarregar, // puxar a tela para baixo atualiza
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho
              const Text(
                'Meu painel',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Olá, ${widget.usuario.nome} · '
                '${doisDigitos(atualizadoEm.day)}/${doisDigitos(atualizadoEm.month)}/${atualizadoEm.year}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Os dois indicadores do funcionário
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  IndicadorCard(
                    titulo: 'Meus EPIs em uso',
                    valor: contadores[0],
                    icone: Icons.outbox,
                    cor: Colors.blue,
                    onTap: () =>
                        abrir(MeusEmprestimosScreen(usuario: widget.usuario)),
                  ),
                  IndicadorCard(
                    titulo: 'Meus treinamentos pendentes',
                    valor: contadores[1],
                    icone: Icons.school,
                    cor: Colors.orange,
                    onTap: () =>
                        abrir(TreinamentosScreen(usuario: widget.usuario)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
