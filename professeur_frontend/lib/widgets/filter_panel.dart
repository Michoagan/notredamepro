import 'package:flutter/material.dart';
import '../models/classe.dart';
import '../models/eleve.dart';
import '../utils/theme.dart';

class FilterPanel extends StatefulWidget {
  final List<Classe> classes;
  final List<Eleve> eleves;
  final Classe? selectedClasse;
  final String selectedType;
  final Eleve? selectedEleve;
  final Function(Classe?, String, Eleve?) onApplyFilters;

  const FilterPanel({
    super.key,
    required this.classes,
    required this.eleves,
    required this.selectedClasse,
    required this.selectedType,
    required this.selectedEleve,
    required this.onApplyFilters,
  });

  @override
  _FilterPanelState createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late Classe? _selectedClasse;
  late String _selectedType;
  late Eleve? _selectedEleve;

  @override
  void initState() {
    super.initState();
    _selectedClasse = widget.selectedClasse;
    _selectedType = widget.selectedType;
    _selectedEleve = widget.selectedEleve;
  }

  // Mettre à jour l'état interne lorsque les propriétés du widget changent
  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedClasse != oldWidget.selectedClasse) {
      _selectedClasse = widget.selectedClasse;
    }
    if (widget.selectedType != oldWidget.selectedType) {
      _selectedType = widget.selectedType;
    }
    if (widget.selectedEleve != oldWidget.selectedEleve) {
      _selectedEleve = widget.selectedEleve;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Filtres d\'analyse',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filtres
            Row(
              children: [
                // Classe
                Expanded(
                  child: DropdownButtonFormField<Classe>(
                    isExpanded: true,
                    initialValue: _selectedClasse,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Toutes les classes',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...widget.classes.map((classe) {
                        return DropdownMenuItem(
                          value: classe,
                          child: Text(
                            classe.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedClasse = value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Classe',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.school_outlined,
                          color: AppTheme.primary),
                      filled: true,
                      fillColor: AppTheme.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Type de note
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(
                          'Tous les types',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'interro',
                        child: Text(
                          'Interrogations',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'devoir',
                        child: Text(
                          'Devoirs',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'trimestrielle',
                        child: Text(
                          'Moyennes trim.',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'generale',
                        child: Text(
                          'Moyennes gén.',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedType = value ?? 'all');
                    },
                    decoration: InputDecoration(
                      labelText: 'Type de note',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category_outlined,
                          color: AppTheme.secondary),
                      filled: true,
                      fillColor: AppTheme.surface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Élève
            DropdownButtonFormField<Eleve>(
              isExpanded: true,
              initialValue: _selectedEleve,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Tous les élèves',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...widget.eleves.map((eleve) {
                  return DropdownMenuItem(
                    value: eleve,
                    child: Text(
                      '${eleve.prenom} ${eleve.nom}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedEleve = value);
              },
              decoration: InputDecoration(
                labelText: 'Élève (optionnel)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon:
                    const Icon(Icons.person_outline, color: AppTheme.accent),
                filled: true,
                fillColor: AppTheme.surface,
              ),
            ),
            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onApplyFilters(
                        _selectedClasse,
                        _selectedType,
                        _selectedEleve,
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Appliquer les filtres'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        // On ne réinitialise pas la classe si possible pour éviter de perdre le contexte
                        // Mais on remet les autres filtres à défaut
                        _selectedType = 'all';
                        _selectedEleve = null;
                      });

                      // Si on a une classe sélectionnée par défaut (via le parent), on la garde
                      // Sinon on remet tout à null. Ici on force un reset complet pour être sûr

                      // NOTE: Pour une meilleure UX, on pourrait garder la classe actuelle.
                      // Pour l'instant on garde le comportement d'origine mais avec une meilleure UI.
                      widget.onApplyFilters(_selectedClasse, 'all', null);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text(
                      'Réinitialiser',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
