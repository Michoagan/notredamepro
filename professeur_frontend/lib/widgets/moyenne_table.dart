import 'package:flutter/material.dart';
import '../models/moyenne.dart';
import '../utils/theme.dart';

class MoyenneTable extends StatelessWidget {
  final List<Moyenne> moyennes;

  const MoyenneTable({super.key, required this.moyennes});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppTheme.primary.withOpacity(0.1),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppTheme.primary.withOpacity(0.05)),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return AppTheme.primary.withOpacity(0.02);
                  }
                  return null;
                },
              ),
              columnSpacing: 24,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              columns: const [
                DataColumn(label: Text('Rang')),
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('I 1')),
                DataColumn(label: Text('I 2')),
                DataColumn(label: Text('I 3')),
                DataColumn(label: Text('I 4')),
                DataColumn(
                    label: Text('Moy. I',
                        style: TextStyle(color: AppTheme.secondary))),
                DataColumn(label: Text('Dev 1')),
                DataColumn(label: Text('Dev 2')),
                DataColumn(
                    label: Text('Moy. T',
                        style: TextStyle(color: AppTheme.primaryDark))),
                DataColumn(label: Text('Coeff')),
                DataColumn(
                    label: Text('Moy. C',
                        style: TextStyle(color: AppTheme.primaryDark))),
                DataColumn(label: Text('Appréciation')),
              ],
              rows: moyennes.map((moyenne) {
                return DataRow(cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: moyenne.rang <= 3
                            ? AppTheme.accent.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        moyenne.rang.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: moyenne.rang <= 3
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text('${moyenne.eleveNom} ${moyenne.elevePrenom}',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(
                      moyenne.premierInterro?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.deuxiemeInterro?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.troisiemeInterro?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.quatriemeInterro?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.moyenneInterro?.toStringAsFixed(2) ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary))),
                  DataCell(Text(
                      moyenne.premierDevoir?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.deuxiemeDevoir?.toStringAsFixed(1) ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.moyenneTrimestrielle?.toStringAsFixed(2) ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark))),
                  DataCell(Text(moyenne.coefficient?.toString() ?? '-',
                      style: const TextStyle(color: AppTheme.textSecondary))),
                  DataCell(Text(
                      moyenne.moyenneCoefficientee?.toStringAsFixed(2) ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark))),
                  DataCell(_buildAppreciationBadge(moyenne.commentaire)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppreciationBadge(String? commentaire) {
    if (commentaire == null) return const Text('-');

    Color badgeColor;
    Color textColor = Colors.white;

    switch (commentaire.toLowerCase()) {
      case 'excellent':
        badgeColor = Colors.green.shade700;
        break;
      case 'très-bien':
      case 'très bien':
        badgeColor = const Color(0xFF17a2b8);
        break;
      case 'bien':
        badgeColor = const Color(0xFF6f42c1);
        break;
      case 'assez-bien':
      case 'assez bien':
        badgeColor = const Color(0xFFffc107);
        textColor = Colors.black87;
        break;
      case 'passable':
        badgeColor = const Color(0xFFfd7e14);
        break;
      case 'insuffisant':
        badgeColor = const Color(0xFFdc3545);
        break;
      case 'faible':
        badgeColor = Colors.red.shade700;
        break;
      case 'médiocre':
        badgeColor = const Color(0xFF343a40);
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        commentaire,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
