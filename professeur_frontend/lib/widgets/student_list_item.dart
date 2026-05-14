import 'package:flutter/material.dart';
import '../models/eleve.dart';
import '../utils/theme.dart';

class StudentListItem extends StatelessWidget {
  final Eleve eleve;
  final bool isAbsent;
  final String? remarks;
  final Function(bool) onAbsenceChanged;

  const StudentListItem({
    super.key,
    required this.eleve,
    required this.isAbsent,
    this.remarks,
    required this.onAbsenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAbsent
            ? AppTheme.error.withOpacity(0.08)
            : AppTheme.bgMedium.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAbsent
              ? AppTheme.error.withOpacity(0.25)
              : AppTheme.surfaceBorder,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor: isAbsent
              ? AppTheme.error.withOpacity(0.15)
              : AppTheme.gold.withOpacity(0.12),
          child: Text(
            '${eleve.prenom[0]}${eleve.nom[0]}',
            style: TextStyle(
              color: isAbsent ? AppTheme.error : AppTheme.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          '${eleve.prenom} ${eleve.nom}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isAbsent ? AppTheme.error : AppTheme.textPrimary,
            decoration: isAbsent ? TextDecoration.lineThrough : null,
            decorationColor: AppTheme.error,
          ),
        ),
        subtitle: remarks != null
            ? Text('Remarque: $remarks',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary))
            : Text(
                'ID: ${eleve.id}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
        trailing: Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isAbsent,
            onChanged: (value) => onAbsenceChanged(value ?? false),
            activeColor: AppTheme.error,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppTheme.textSecondary, width: 1.5),
          ),
        ),
        onTap: () => onAbsenceChanged(!isAbsent),
      ),
    );
  }
}
