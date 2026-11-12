import 'package:flutter/material.dart';

class IndicadorCard extends StatelessWidget {
  final String titulo;
  final int valor;
  final IconData icone;
  final MaterialColor cor;
  final VoidCallback? onTap;

  const IndicadorCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cor.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icone, color: cor.shade700, size: 24),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              Text(
                '$valor',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: cor.shade800,
                ),
              ),
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}