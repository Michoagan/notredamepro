import 'package:flutter/material.dart';
import '../models/eleve.dart';
import '../utils/theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final List<MapEntry<String, dynamic>> extremeNotes;
  final List<Eleve> eleves;

  const ConfirmationDialog({
    super.key,
    required this.extremeNotes,
    required this.eleves,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.error),
          SizedBox(width: 8),
          Text('Notes invextrêmes',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.error,
                  fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Les notes suivantes sont en dehors de la plage normale (0-20):',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: extremeNotes.map((entry) {
                  final eleve = eleves.firstWhere(
                    (e) => e.id.toString() == entry.key,
                    orElse: () => Eleve(
                        id: 0,
                        nom: 'Inconnu',
                        prenom: '',
                        dateNaissance: DateTime.now(),
                        lieuNaissance: '',
                        genre: '',
                        adresse: '',
                        telephone: '',
                        email: '',
                        classeId: 0,
                        dateInscription: DateTime.now(),
                        isActive: true),
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.error.withOpacity(0.1),
                      radius: 16,
                      child: const Text(
                        '!',
                        style: TextStyle(
                            color: AppTheme.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text('${eleve.prenom} ${eleve.nom}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Voulez-vous vraiment enregistrer ces notes ?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Confirmer tout de même'),
        ),
      ],
      actionsPadding: const EdgeInsets.all(16),
    );
  }
}
