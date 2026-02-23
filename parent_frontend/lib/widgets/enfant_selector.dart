import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/eleve.dart';

class EnfantSelectorWidget extends StatelessWidget {
  final List<Eleve> enfants;
  final Eleve? selectedEnfant;
  final ValueChanged<Eleve> onEnfantSelected;

  const EnfantSelectorWidget({
    super.key,
    required this.enfants,
    required this.selectedEnfant,
    required this.onEnfantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (enfants.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      height: 110,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: enfants.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final enfant = enfants[index];
          final isSelected = selectedEnfant?.id == enfant.id;

          return GestureDetector(
            onTap: () => onEnfantSelected(enfant),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 85,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppTheme.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${enfant.prenom[0].toUpperCase()}${enfant.nom[0].toUpperCase()}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    enfant.prenom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
