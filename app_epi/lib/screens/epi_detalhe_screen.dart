import 'package:flutter/material.dart';

import '../models/epi.dart';
import '../models/usuario.dart';
import '../services/api_config.dart';
import '../services/api_erro.dart';
import '../services/emprestimo_service.dart';

class EpiDetalheScreen extends StatefulWidget {
  final Epi epi; // EPI escolhido na lista
  final Usuario usuario; // funcionário logado

  const EpiDetalheScreen({super.key, required this.epi, required this.usuario});

  @override
  State<EpiDetalheScreen> createState() => _EpiDetalheScreenState();
}

class _EpiDetalheScreenState extends State<EpiDetalheScreen> {
  final formKey = GlobalKey<FormState>();
  final observacaoController = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    observacaoController.dispose();
    super.dispose();
  }

  Future<void> solicitarEmprestimo() async {
    // 1. Valida o formulário antes de chamar a API
    if (!formKey.currentState!.validate()) return;

    // Exercício 2: Mostra AlertDialog de confirmação antes de enviar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Solicitação'),
        content: Text('Confirma a solicitação de "${widget.epi.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    if (!mounted) return;

    setState(() {
      carregando = true;
    });

    try {
      // 2. Envia o POST
      await EmprestimoService().solicitar(
        funcionarioId: widget.usuario.id,
        epiId: widget.epi.id,
        observacao: observacaoController.text.trim(),
      );

      if (!mounted) return;

      // 3. Sucesso: avisa e volta para a lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada! Aguarde a aprovação.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // 4. Erro: mostra a mensagem que veio da API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemDeErro(e)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final epi = widget.epi;

    // O app só libera o botão se o EPI puder ser emprestado
    final podeSolicitar = !epi.caVencido && epi.quantidadeDisponivel > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do EPI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Foto do EPI
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: epi.imagemUrl.isEmpty
                    ? _imagemIndisponivel()
                    : Image.network(
                        '${ApiConfig.baseUrl}${epi.imagemUrl}',
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagemIndisponivel();
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Dados do EPI
              Text(
                epi.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                epi.categoria,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Divider(height: 30),

              linhaInfo(Icons.verified, 'CA', epi.ca),
              linhaInfo(
                Icons.event,
                'Validade do CA',
                epi.validadeFormatada,
                cor: epi.caVencido ? Colors.red : null,
              ),
              linhaInfo(
                Icons.inventory_2,
                'Disponível',
                '${epi.quantidadeDisponivel} un.',
              ),
              const Divider(height: 30),

              // Formulário de solicitação
              Text(
                'Solicitante: ${widget.usuario.nome} '
                '(matrícula ${widget.usuario.matricula})',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: observacaoController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Motivo da solicitação',
                  hintText: 'Ex.: capacete atual está trincado',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o motivo da solicitação';
                  }
                  if (valor.trim().length < 5) {
                    return 'Escreva pelo menos 5 caracteres';
                  }
                  return null; // null = campo válido
                },
              ),
              const SizedBox(height: 8),

              // Aviso quando o EPI não pode ser emprestado
              if (!podeSolicitar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    epi.caVencido
                        ? 'CA vencido: este EPI não pode ser emprestado.'
                        : 'EPI sem estoque no momento.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Botão Solicitar Empréstimo
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (carregando || !podeSolicitar)
                      ? null
                      : solicitarEmprestimo,
                  icon: carregando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Solicitar Empréstimo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Imagem usada quando o EPI não tem foto ou a foto não carrega.
  Widget _imagemIndisponivel() {
    return Container(
      height: 200,
      color: Colors.blue.shade50,
      child: const Icon(Icons.health_and_safety, size: 80, color: Colors.blue),
    );
  }

  // Monta uma linha "ícone + rótulo + valor"
  Widget linhaInfo(IconData icone, String rotulo, String valor, {Color? cor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, color: cor ?? Colors.blue),
          const SizedBox(width: 10),
          Text(
            '$rotulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(valor, style: TextStyle(color: cor)),
          ),
        ],
      ),
    );
  }
}
