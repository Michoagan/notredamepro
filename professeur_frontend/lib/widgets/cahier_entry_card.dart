import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cahier_texte.dart';
import '../utils/theme.dart';

class CahierEntryCard extends StatelessWidget {
  final CahierTexte entry;
  final String? classeNom;

  const CahierEntryCard({super.key, required this.entry, this.classeNom});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      // Theme handles elevation, shape, and color automatically now!
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
                        classeNom ?? "Classe",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(entry.dateCours),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 16, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.dureeCours}h',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            const Text(
              'Notion abordée:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.notionCours,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Début: ${entry.heureDebut}',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
  }
}
