import 'package:flutter/material.dart';
import '../models/eleve.dart';
import '../utils/theme.dart';

class NoteInputDialog extends StatefulWidget {
  final Eleve eleve;
  final double? currentValue;
  final Function(double) onSave;

  const NoteInputDialog({
    super.key,
    required this.eleve,
    this.currentValue,
    required this.onSave,
  });

  @override
  _NoteInputDialogState createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<NoteInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  double _noteValue = 0;

  @override
  void initState() {
    super.initState();
    _noteValue = widget.currentValue ?? 0;
    _noteController = TextEditingController(
      text: widget.currentValue?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Saisir la note',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    '${widget.eleve.prenom[0]}${widget.eleve.nom[0]}',
                    style: const TextStyle(
                        color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.eleve.prenom} ${widget.eleve.nom}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _noteController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Note /20',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 2),
                ),
                suffixText: '/ 20',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir une note';
                }
                final note = double.tryParse(value.replaceAll(',', '.'));
                if (note == null || note < 0 || note > 20) {
                  return 'Note invalide (0-20)';
                }
                return null;
              },
              onChanged: (value) {
                final note = double.tryParse(value.replaceAll(',', '.'));
                if (note != null) {
                  setState(() => _noteValue = note);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_noteValue < 10)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Attention: Note inférieure à la moyenne',
                      style: TextStyle(
                          color: AppTheme.error.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else if (_noteValue >= 16)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_outline,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Excellent travail !',
                      style: TextStyle(
                          color: Colors.green.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_noteValue);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Enregistrer'),
        ),
      ],
      actionsPadding: const EdgeInsets.all(16),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
