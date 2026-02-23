import 'package:flutter/material.dart';
import '../models/classe.dart';
import '../screens/presences_screen.dart';
import '../utils/theme.dart';

class ClasseCard extends StatelessWidget {
  final Classe classe;

  const ClasseCard({super.key, required this.classe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresencesScreen(
                  initialClasse: classe,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20), // Increased padding slightly
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary
                            .withOpacity(0.08), // Softer background
                        shape: BoxShape.circle, // Rounded icon bg
                      ),
                      child: const Icon(Icons.school,
                          color: AppTheme.primary, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${classe.elevesCount} Élèves',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  classe.nom,
                  style: const TextStyle(
                    fontSize: 20, // Slightly larger
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Niveau ${classe.niveau}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Voir présences',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: AppTheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
