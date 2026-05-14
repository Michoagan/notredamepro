import 'package:flutter/material.dart';
import '../models/conseil.dart';
import '../utils/theme.dart';

class ConseilCard extends StatelessWidget {
  final Conseil conseil;

  const ConseilCard({super.key, required this.conseil});

  @override
  Widget build(BuildContext context) {
    final _Style style = _styleFor(conseil.type);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: style.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header dégradé ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    style.primary,
                    style.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Icône dans cercle semi-transparent
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: Icon(style.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conseil Pédagogique',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conseil.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Badge nombre de conseils
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${conseil.recommandations.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste des recommandations ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: conseil.recommandations
                    .asMap()
                    .entries
                    .map((entry) => _RecItem(
                          text: entry.value,
                          index: entry.key,
                          color: style.primary,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _Style _styleFor(String type) {
    if (type.contains('Interro')) {
      return _Style(
        primary: const Color(0xFFD97706),
        secondary: const Color(0xFFB45309),
        icon: Icons.assignment_late_outlined,
      );
    } else if (type.contains('Devoir')) {
      return _Style(
        primary: const Color(0xFF059669),
        secondary: const Color(0xFF047857),
        icon: Icons.assignment_turned_in_outlined,
      );
    } else if (type.contains('Trimestre')) {
      return _Style(
        primary: const Color(0xFF0891B2),
        secondary: const Color(0xFF0E7490),
        icon: Icons.insights_outlined,
      );
    } else if (type.contains('Général') || type.contains('General')) {
      return _Style(
        primary: const Color(0xFF7C3AED),
        secondary: const Color(0xFF6D28D9),
        icon: Icons.psychology_outlined,
      );
    } else {
      return _Style(
        primary: AppTheme.primary,
        secondary: AppTheme.primaryLight,
        icon: Icons.lightbulb_outline_rounded,
      );
    }
  }
}

class _Style {
  final Color primary;
  final Color secondary;
  final IconData icon;
  const _Style(
      {required this.primary, required this.secondary, required this.icon});
}

class _RecItem extends StatelessWidget {
  final String text;
  final int index;
  final Color color;

  const _RecItem(
      {required this.text, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro ou point doré
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
