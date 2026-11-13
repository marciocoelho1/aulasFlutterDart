import 'package:flutter/material.dart';

import '../models/dashboard.dart';
import '../models/usuario.dart';
import '../services/api_erro.dart';
import '../services/dashboard_service.dart';
import '../widgets/indicador_card.dart';
import 'epi_screen.dart';
import 'funcionario_screen.dart';
import 'solicitacoes_screen.dart';

// Painel do técnico. Não tem Scaffold próprio:
// ele é exibido dentro do body da MainScreen.
class DashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Dashboard> futuroDados;
  DateTime atualizadoEm = DateTime.now();

  @override
  void initState() {
    super.initState();
    futuroDados = DashboardService().buscar(widget.usuario.id);
  }

  Future<void> recarregar() async {
    final futuro = DashboardService().buscar(widget.usuario.id);
    setState(() {
      futuroDados = futuro;
      atualizadoEm = DateTime.now();
    });
    try {
      await futuro; // o RefreshIndicator espera terminar
    } catch (_) {
      // O FutureBuilder abaixo já exibe a mensagem de erro.
    }
  }

  // Abre outra tela e, ao voltar, atualiza os números
  void abrir(Widget tela) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela)).then((_) {
      if (mounted) recarregar();
    });
  }

  String doisDigitos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();

    // Telas largas (computador) = 3 colunas; celular = 2 colunas
    final largura = MediaQuery.of(context).size.width;
    final colunas = largura >= 700 ? 3 : 2;

    return FutureBuilder<Dashboard>(
      future: futuroDados,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(mensagemDeErro(snapshot.error)));
        }

        final d = snapshot.data!;

        return RefreshIndicator(
          onRefresh: recarregar, // puxar a tela para baixo atualiza
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho
              const Text(
                'Painel de Segurança do Trabalho',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Olá, ${widget.usuario.nome} · '
                '${doisDigitos(hoje.day)}/${doisDigitos(hoje.month)}/${hoje.year}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Alerta: só aparece se houver CA vencido
              if (d.caVencidos > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${d.caVencidos} EPI(s) com CA vencido. '
                          'Retire de uso e providencie a substituição.',
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                ),

              // Grade de indicadores
              GridView.count(
                crossAxisCount: colunas,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // proporção largura/altura de cada card
                childAspectRatio: colunas == 2 ? 0.95 : 1.6,
                shrinkWrap: true, // ocupa só o espaço necessário
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  IndicadorCard(
                    titulo: 'EPIs cadastrados',
                    valor: d.episCadastrados,
                    icone: Icons.inventory_2,
                    cor: Colors.indigo,
                    onTap: () => abrir(EpiScreen(usuario: widget.usuario)),
                  ),
                  IndicadorCard(
                    titulo: 'EPIs emprestados',
                    valor: d.episEmprestados,
                    icone: Icons.outbox,
                    cor: Colors.blue,
                    onTap: () =>
                        abrir(SolicitacoesScreen(usuario: widget.usuario)),
                  ),
                  IndicadorCard(
                    titulo: 'EPIs devolvidos',
                    valor: d.episDevolvidos,
                    icone: Icons.assignment_return,
                    cor: Colors.green,
                  ),
                  IndicadorCard(
                    titulo: 'CA vencidos',
                    valor: d.caVencidos,
                    icone: Icons.gpp_bad,
                    cor: Colors.red,
                    onTap: () => abrir(
                      EpiScreen(
                        usuario: widget.usuario,
                        filtro: FiltroEpi.caVencido,
                      ),
                    ),
                  ),
                  IndicadorCard(
                    titulo: 'Solicitações pendentes',
                    valor: d.solicitacoesPendentes,
                    icone: Icons.pending_actions,
                    cor: Colors.amber,
                    onTap: () =>
                        abrir(SolicitacoesScreen(usuario: widget.usuario)),
                  ),
                  IndicadorCard(
                    titulo: 'Treinamentos pendentes',
                    valor: d.treinamentosPendentes,
                    icone: Icons.school,
                    cor: Colors.orange,
                  ),
                  IndicadorCard(
                    titulo: 'Funcionários cadastrados',
                    valor: d.funcionariosCadastrados,
                    icone: Icons.people,
                    cor: Colors.teal,
                    onTap: () =>
                        abrir(FuncionarioScreen(usuario: widget.usuario)),
                  ),
                  IndicadorCard(
                    titulo: 'Estoque baixo',
                    valor: d.estoqueBaixo,
                    icone: Icons.production_quantity_limits,
                    cor: Colors.deepOrange,
                    onTap: () => abrir(
                      EpiScreen(
                        usuario: widget.usuario,
                        filtro: FiltroEpi.estoqueBaixo,
                      ),
                    ),
                  ),
                ],
              ),

              // Rodapé
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Atualizado às ${doisDigitos(atualizadoEm.hour)}:'
                    '${doisDigitos(atualizadoEm.minute)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: recarregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar'),
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
