import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/eleve.dart';
import '../models/note_analysis.dart';
import '../widgets/filter_panel.dart';
import '../widgets/notes_chart.dart';
import '../widgets/conseil_card.dart';
import '../widgets/export_button.dart';
import '../utils/theme.dart';

class AnalyseNotesScreen extends StatefulWidget {
  const AnalyseNotesScreen({super.key});

  @override
  _AnalyseNotesScreenState createState() => _AnalyseNotesScreenState();
}

class _AnalyseNotesScreenState extends State<AnalyseNotesScreen> {
  final ApiService _apiService = ApiService();
  List<Classe> _classes = [];
  List<Eleve> _eleves = [];
  Classe? _selectedClasse;
  String _selectedType = 'all';
  Eleve? _selectedEleve;
  NoteAnalysis? _noteAnalysis;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final classes = await _apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
        // Sélectionner automatiquement la première classe si disponible
        if (classes.isNotEmpty) {
          _selectedClasse = classes.first;
          _loadEleves(); // Charger les élèves de la classe sélectionnée
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des classes: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _loadEleves() async {
    // Capturez la valeur dans une variable locale
    final selectedClasse = _selectedClasse;
    if (selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final eleves = await _apiService.getElevesByClasse(selectedClasse.id);
      setState(() {
        _eleves = eleves;
        _isLoading = false;
      });

      _loadAnalysis();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des élèves: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _loadAnalysis() async {
    if (_selectedClasse == null) {
      setState(() => _isLoading = false);
      return;
    }

    final classeId = _selectedClasse!.id;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final analysis = await _apiService.getNoteAnalysis(
        classeId: classeId, // Passez comme paramètre nommé
        type: _selectedType,
        eleveId: _selectedEleve?.id,
      );

      setState(() {
        _noteAnalysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement de l\'analyse: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement de l\'analyse: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  // AJOUTEZ CETTE MÉTHODE MANQUANTE
  void _applyFilters(Classe? classe, String type, Eleve? eleve) {
    setState(() {
      _selectedClasse = classe;
      _selectedType = type;
      _selectedEleve = eleve;
    });

    if (classe != null) {
      _loadEleves(); // Recharger les élèves et l'analyse
    } else {
      // Si aucune classe n'est sélectionnée, réinitialiser l'analyse
      setState(() {
        _noteAnalysis = null;
        _eleves = [];
      });
    }
  }

  void _refreshData() {
    if (_selectedClasse != null) {
      _loadEleves();
    } else {
      _loadClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des Notes'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Actualiser',
            color: Colors.white,
          ),
          ExportButton(
            onExport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Exportation en cours...'),
                    backgroundColor: AppTheme.secondary),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Impression en cours...'),
                    backgroundColor: AppTheme.secondary),
              );
            },
            tooltip: 'Imprimer',
            color: Colors.white,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                                  'Tableau de Bord',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Analyse détaillée des performances',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            if (_selectedClasse != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _selectedClasse!.displayName,
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

                      // Filtres
                      FilterPanel(
                        classes: _classes,
                        eleves: _eleves,
                        selectedClasse: _selectedClasse,
                        selectedType: _selectedType,
                        selectedEleve: _selectedEleve,
                        onApplyFilters: _applyFilters,
                      ),
                      const SizedBox(height: 24),

                      // Graphique
                      if (_noteAnalysis != null &&
                          _noteAnalysis!.labels.isNotEmpty)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Évolution des notes',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppTheme.primary),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.secondary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _selectedType == 'all'
                                            ? 'Tous types'
                                            : _selectedType == 'interro'
                                                ? 'Interrogations'
                                                : _selectedType == 'devoir'
                                                    ? 'Devoirs'
                                                    : _selectedType ==
                                                            'trimestrielle'
                                                        ? 'Moyenne T.'
                                                        : 'Moyenne G.',
                                        style: const TextStyle(
                                            color: AppTheme.secondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 300,
                                  child: NotesChart(
                                    labels: _noteAnalysis!.labels,
                                    datasets: _noteAnalysis!.datasets,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_noteAnalysis != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune donnée à afficher pour cette sélection',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Conseils pédagogiques
                      if (_noteAnalysis != null &&
                          _noteAnalysis!.conseils.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Conseils pédagogiques',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._noteAnalysis!.conseils.map((conseil) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ConseilCard(conseil: conseil),
                              );
                            }).toList(),
                          ],
                        ),

                      // Message si aucune classe n'est sélectionnée
                      if (_classes.isEmpty && !_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.school_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Aucune classe disponible',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
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
