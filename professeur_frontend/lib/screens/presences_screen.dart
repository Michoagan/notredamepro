import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/eleve.dart';
import '../models/presence.dart';
import '../widgets/student_list_item.dart';
import '../widgets/date_picker.dart';
import '../utils/theme.dart';
import '../widgets/premium_feedback.dart';

class PresencesScreen extends StatefulWidget {
  final Classe? initialClasse;

  const PresencesScreen({this.initialClasse, super.key});

  @override
  _PresencesScreenState createState() => _PresencesScreenState();
}

class _PresencesScreenState extends State<PresencesScreen> {
  late List<Classe> _classes = [];
  Classe? _selectedClasse;
  DateTime _selectedDate = DateTime.now();
  // Removed _selectedMatiere
  List<Eleve> _eleves = [];
  Map<int, Presence> _existingPresences = {};
  Set<int> _absents = {};
  String _generalRemarks = '';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _selectAll = false;
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _selectedClasse = widget.initialClasse;
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final classes = await apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });

      // Si une classe initiale est fournie, charger ses données directement
      if (_selectedClasse != null && !_hasLoadedInitialData) {
        _hasLoadedInitialData = true;
        _loadElevesAndPresences();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des classes: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  // Removed _loadMatieres

  Future<void> _loadElevesAndPresences() async {
    if (_selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Charger les élèves
      final eleves = await apiService.getElevesByClasse(_selectedClasse!.id);

      // Charger les présences existantes
      final dateString = _selectedDate.toIso8601String().split('T')[0];
      final existingPresences = await apiService.getPresencesByClasse(
          _selectedClasse!.id, dateString);

      setState(() {
        _eleves = eleves;
        _existingPresences = {
          for (var presence in existingPresences) presence.eleveId: presence,
        };

        // Initialiser les absences basées sur les présences existantes
        _absents = Set.from(
          _existingPresences.values
              .where((presence) => !presence.present)
              .map((presence) => presence.eleveId),
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des données: $e')),
      );
    }
  }

  Future<void> _savePresences() async {
    if (_selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final dateString = _selectedDate.toIso8601String().split('T')[0];

      final result = await apiService.storePresences(
        classeId: _selectedClasse!.id,
        date: dateString,
        cours: 0, // Ignored by backend as it auto-deduces the subject
        absents: _absents.toList(),
        remarquesGenerales: _generalRemarks,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (mounted) {
          PremiumFeedback.showSuccess(context,
              message: 'Présences enregistrées !');
        }

        // Recharger les données
        _loadElevesAndPresences();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement: $e')),
      );
    }
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      _selectAll = value;
      if (value) {
        _absents = Set.from(_eleves.map((e) => e.id));
      } else {
        _absents.clear();
      }
    });
  }

  void _toggleAbsent(int eleveId, bool isAbsent) {
    setState(() {
      if (isAbsent) {
        _absents.add(eleveId);
      } else {
        _absents.remove(eleveId);
      }
      // Mettre à jour l'état "select all"
      _selectAll = _absents.length == _eleves.length;
    });
  }

  List<Eleve> get _filteredEleves {
    if (_searchQuery.isEmpty) return _eleves;
    return _eleves.where((eleve) {
      final fullName = '${eleve.prenom} ${eleve.nom}'.toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Présences'),
        backgroundColor: AppTheme.primary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
        ],
      ),
      body: _isLoading && _eleves.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Faire l\'appel',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gérez les présences de vos classes',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Formulaire de sélection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Sélection de la classe
                          DropdownButtonFormField<Classe>(
                            value: _selectedClasse,
                            items: _classes.map((classe) {
                              return DropdownMenuItem(
                                value: classe,
                                child: Text('${classe.displayName}'),
                              );
                            }).toList(),
                            onChanged: (classe) {
                              setState(() {
                                _selectedClasse = classe;
                                _eleves.clear();
                                _absents.clear();
                                _generalRemarks = '';
                              });
                              if (classe != null) {
                                _loadElevesAndPresences();
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Sélectionner une classe',
                              prefixIcon: const Icon(Icons.school_rounded,
                                  color: AppTheme.primary),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: AppTheme.background,
                            ),
                            hint: const Text('Choisir une classe'),
                          ),
                          const SizedBox(height: 16),

                          DatePicker(
                            selectedDate: _selectedDate,
                            onDateChanged: (date) {
                              setState(() => _selectedDate = date);
                              if (_selectedClasse != null) {
                                _loadElevesAndPresences();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Liste des élèves
                  if (_selectedClasse != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête de la liste
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Liste des élèves',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_eleves.length} élèves',
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Barre de recherche
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Rechercher un élève...',
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: AppTheme.textSecondary),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: AppTheme.background,
                              ),
                              onChanged: (query) {
                                setState(() => _searchQuery = query);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Option "Marquer tous absents"
                            if (_eleves.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _selectAll,
                                      activeColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      onChanged: (value) =>
                                          _toggleSelectAll(value ?? false),
                                    ),
                                    const Text(
                                      'Marquer tous absents',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary),
                                    ),
                                    const Spacer(),
                                    if (_absents.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: AppTheme.warning,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          '${_absents.length} Absent(s)',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: AppTheme.success,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: const Text(
                                          'Tous présents',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Liste des élèves
                            if (_eleves.isEmpty)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                child: const Column(
                                  children: [
                                    Icon(Icons.group_off_rounded,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'Aucun élève dans cette classe',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )
                            else if (_filteredEleves.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                    child: Text(
                                        'Aucun élève trouvé pour cette recherche.',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary))),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredEleves.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final eleve = _filteredEleves[index];
                                  final isAbsent = _absents.contains(eleve.id);

                                  return StudentListItem(
                                    eleve: eleve,
                                    isAbsent: isAbsent,
                                    onAbsenceChanged: (absent) =>
                                        _toggleAbsent(eleve.id, absent),
                                  );
                                },
                              ),

                            // Remarques générales
                            if (_eleves.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Remarques générales',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Incident, retard global, etc...',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  filled: true,
                                  fillColor: AppTheme.background,
                                ),
                                onChanged: (value) => _generalRemarks = value,
                              ),
                            ],

                            // Bouton d'enregistrement
                            if (_eleves.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _savePresences,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2),
                                            )
                                          : const Text(
                                              'ENREGISTRER LES PRÉSENCES'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Message d'information
                  if (_selectedClasse == null)
                    Container(
                      margin: const EdgeInsets.only(top: 40),
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.touch_app_outlined,
                                size: 64, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Sélectionnez une classe ci-dessus\npour commencer l\'appel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
