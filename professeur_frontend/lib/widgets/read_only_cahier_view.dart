import 'package:flutter/material.dart';
import '../models/cahier_texte.dart';
import '../utils/theme.dart';

class ReadOnlyCahierView extends StatelessWidget {
  final CahierTexte cahier;
  final VoidCallback onBack;
  final String? classeNom;

  const ReadOnlyCahierView({
    super.key,
    required this.cahier,
    required this.onBack,
    this.classeNom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppTheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cahier de texte',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${classeNom ?? "Classe"} - ${_formatDate(cahier.dateCours)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Enregistré',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildReadOnlyField(
                    'Durée',
                    '${cahier.dureeCours} heure(s)',
                    Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReadOnlyField(
                    'Heure de début',
                    cahier.heureDebut,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildReadOnlyField(
              'Notion du jour',
              cahier.notionCours,
              Icons.subject,
              isMultiline: true,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ce cahier de texte a déjà été soumis. Pour toute modification, veuillez contacter l\'administration.',
                      style:
                          TextStyle(color: AppTheme.primaryDark, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon,
      {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 15, color: AppTheme.textPrimary, height: 1.4),
            maxLines: isMultiline ? 10 : 1,
            overflow:
                isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
