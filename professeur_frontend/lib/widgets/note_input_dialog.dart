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
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec gradient doré
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF060D1F), Color(0xFF1A237E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.eleve.prenom[0]}${widget.eleve.nom[0]}',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saisir la note',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${widget.eleve.prenom} ${widget.eleve.nom}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Champ note avec style premium
              TextFormField(
                controller: _noteController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.gold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Note /20',
                  suffixText: '/ 20',
                  suffixStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
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
              const SizedBox(height: 12),

              // Indicateur de niveau
              if (_noteValue > 0) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _noteValue < 10
                        ? AppTheme.error.withOpacity(0.1)
                        : _noteValue >= 16
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _noteValue < 10
                          ? AppTheme.error.withOpacity(0.3)
                          : _noteValue >= 16
                              ? AppTheme.success.withOpacity(0.3)
                              : AppTheme.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _noteValue < 10
                            ? Icons.warning_amber_rounded
                            : _noteValue >= 16
                                ? Icons.star_rounded
                                : Icons.check_circle_outline_rounded,
                        color: _noteValue < 10
                            ? AppTheme.error
                            : _noteValue >= 16
                                ? AppTheme.success
                                : AppTheme.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _noteValue < 10
                            ? 'Note inférieure à la moyenne'
                            : _noteValue >= 16
                                ? 'Excellent travail !'
                                : 'Note satisfaisante',
                        style: TextStyle(
                          color: _noteValue < 10
                              ? AppTheme.error
                              : _noteValue >= 16
                                  ? AppTheme.success
                                  : AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(_noteValue);
                        }
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
