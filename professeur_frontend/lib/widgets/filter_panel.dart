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
    _selectedType   = widget.selectedType;
    _selectedEleve  = widget.selectedEleve;
  }

  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedClasse != oldWidget.selectedClasse) {
      _selectedClasse = widget.selectedClasse;
    }
    if (widget.selectedType != oldWidget.selectedType) {
      _selectedType = widget.selectedType;
    }
    if (widget.eleves != oldWidget.eleves) {
      final stillPresent = _selectedEleve != null &&
          widget.eleves.any((e) => e.id == _selectedEleve!.id);
      if (!stillPresent) {
        _selectedEleve = null;
      } else {
        _selectedEleve = widget.eleves.firstWhere(
          (e) => e.id == _selectedEleve!.id,
          orElse: () => _selectedEleve!,
        );
      }
    }
    if (widget.selectedEleve != oldWidget.selectedEleve) {
      _selectedEleve = widget.selectedEleve;
    }
  }

  InputDecoration _dec(String label, IconData icon, Color iconColor) =>
      InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre ──────────────────────────────────────────
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_list_rounded,
                  color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Filtres d\'analyse',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppTheme.primary)),
          ]),
          const SizedBox(height: 14),

          // ── Ligne 1 : Classe + Type ────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 300) {
              return Column(children: [
                _classeDropdown(),
                const SizedBox(height: 10),
                _typeDropdown(),
              ]);
            }
            return Row(children: [
              Expanded(child: _classeDropdown()),
              const SizedBox(width: 10),
              Expanded(child: _typeDropdown()),
            ]);
          }),

          const SizedBox(height: 10),

          // ── Ligne 2 : Élève ────────────────────────────────
          _eleveDropdown(),

          const SizedBox(height: 16),

          // ── Boutons ────────────────────────────────────────
          Row(children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onApplyFilters(
                    _selectedClasse, _selectedType, _selectedEleve),
                  icon: const Icon(Icons.psychology_rounded, size: 18),
                  label: const Text('Analyser',
                      overflow: TextOverflow.ellipsis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedType  = 'all';
                      _selectedEleve = null;
                    });
                    widget.onApplyFilters(_selectedClasse, 'all', null);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label:
                      const Text('Reset', overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(color: AppTheme.surfaceBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _classeDropdown() {
    return DropdownButtonFormField<Classe>(
      isExpanded: true,
      initialValue: _selectedClasse,
      items: [
        const DropdownMenuItem(
            value: null,
            child: Text('Toutes les classes',
                overflow: TextOverflow.ellipsis)),
        ...widget.classes.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.displayName, overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (v) => setState(() => _selectedClasse = v),
      decoration:
          _dec('Classe', Icons.school_outlined, AppTheme.primary),
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _selectedType,
      items: const [
        DropdownMenuItem(
            value: 'all',
            child: Text('Tous types', overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(
            value: 'interro',
            child: Text('Interros', overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(
            value: 'devoir',
            child: Text('Devoirs', overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(
            value: 'trimestrielle',
            child: Text('Moy. Trim.', overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(
            value: 'generale',
            child: Text('Moy. Gén.', overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) => setState(() => _selectedType = v ?? 'all'),
      decoration:
          _dec('Type de note', Icons.category_outlined, AppTheme.secondary),
    );
  }

  Widget _eleveDropdown() {
    final seen = <int>{};
    final uniqueEleves =
        widget.eleves.where((e) => seen.add(e.id)).toList();

    final resolvedEleve = _selectedEleve == null
        ? null
        : uniqueEleves.any((e) => e.id == _selectedEleve!.id)
            ? uniqueEleves.firstWhere((e) => e.id == _selectedEleve!.id)
            : null;

    return DropdownButtonFormField<Eleve>(
      isExpanded: true,
      value: resolvedEleve,
      items: [
        const DropdownMenuItem(
            value: null,
            child: Text('Vue classe entière',
                overflow: TextOverflow.ellipsis)),
        ...uniqueEleves.map((e) => DropdownMenuItem(
              value: e,
              child: Text('${e.prenom} ${e.nom}',
                  overflow: TextOverflow.ellipsis),
            )),
      ],
      onChanged: (v) => setState(() => _selectedEleve = v),
      decoration:
          _dec('Élève (optionnel)', Icons.person_outline, AppTheme.accent),
    );
  }
}
