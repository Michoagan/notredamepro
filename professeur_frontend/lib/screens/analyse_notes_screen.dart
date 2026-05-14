import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/eleve.dart';
import '../models/note_analysis.dart';
import '../widgets/filter_panel.dart';
import '../widgets/notes_chart.dart';
import '../widgets/conseil_card.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';

class AnalyseNotesScreen extends StatefulWidget {
  final int profMatiereId;
  final String profMatiereName;

  const AnalyseNotesScreen({
    super.key,
    required this.profMatiereId,
    required this.profMatiereName,
  });

  @override
  _AnalyseNotesScreenState createState() => _AnalyseNotesScreenState();
}

class _AnalyseNotesScreenState extends State<AnalyseNotesScreen> {
  List<Classe> _classes = [];
  List<Eleve> _eleves = [];
  Classe? _selectedClasse;
  String _selectedType = 'all';
  Eleve? _selectedEleve;
  NoteAnalysis? _noteAnalysis;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Matière du prof (passée depuis le profil)
  int get _matiereId => widget.profMatiereId;
  String get _matiereName => widget.profMatiereName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClasses());
  }

  ApiService get _apiService =>
      Provider.of<ApiService>(context, listen: false);

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
        if (classes.isNotEmpty) {
          _selectedClasse = classes.first;
          _loadEleves();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

  Future<void> _loadEleves() async {
    final selectedClasse = _selectedClasse;
    if (selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final eleves = await _apiService.getElevesByClasse(selectedClasse.id);
      setState(() {
        _eleves    = eleves;
        _isLoading = false;
      });
      _loadAnalysis();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des élèves: $e');
    }
  }

  Future<void> _loadAnalysis() async {
    if (_selectedClasse == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final analysis = await _apiService.getNoteAnalysis(
        classeId: _selectedClasse!.id,
        type: _selectedType,
        eleveId: _selectedEleve?.id,
        matiereId: _matiereId > 0 ? _matiereId : null,
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
      _showErrorSnackBar(_errorMessage);
    }
  }

  void _applyFilters(Classe? classe, String type, Eleve? eleve) {
    setState(() {
      _selectedClasse = classe;
      _selectedType   = type;
      _selectedEleve  = eleve;
    });

    if (classe != null) {
      _loadEleves();
    } else {
      setState(() {
        _noteAnalysis = null;
        _eleves       = [];
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Analyse Pédagogique',
        subtitle: _selectedClasse != null
          ? '${_selectedClasse!.displayName} • $_matiereName'
          : null,
        actions: [
          PremiumActionBtn(
            icon: Icons.refresh_rounded,
            onTap: _refreshData,
          ),
          PremiumActionBtn(
            icon: Icons.picture_as_pdf_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Exportation PDF en cours...'),
                    backgroundColor: AppTheme.secondary),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                  const SizedBox(height: 16),
                  Text(_errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  
                  FilterPanel(
                    classes:        _classes,
                    eleves:         _eleves,
                    selectedClasse: _selectedClasse,
                    selectedType:   _selectedType,
                    selectedEleve:  _selectedEleve,
                    onApplyFilters: _applyFilters,
                  ),
                  const SizedBox(height: 24),

                  if (_noteAnalysis != null && _noteAnalysis!.statistiques != null)
                    _buildKpiGrid(_noteAnalysis!),

                  const SizedBox(height: 24),

                  if (_noteAnalysis != null && _noteAnalysis!.labels.isNotEmpty)
                    _buildChartCard(),

                  if (_noteAnalysis != null && _noteAnalysis!.conseils.isNotEmpty)
                    _buildConseilsSection(),

                  if (_noteAnalysis != null && _noteAnalysis!.notesExamens != null)
                    _buildNotesExamensList(_noteAnalysis!.notesExamens!),

                  if (_classes.isEmpty && !_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('Aucune classe disponible',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                ],
              ),
            ),
          
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: AppTheme.bgDark.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tableau de Bord',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Analyse détaillée et IA Pédagogique',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          if (_selectedClasse != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedClasse!.displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(NoteAnalysis analysis) {
    final bool isIndiv = analysis.isIndividual;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildKpiCard(
          title: isIndiv ? 'Moyenne Générale' : 'Moyenne Classe',
          value: '${analysis.moyenneGenerale.toStringAsFixed(2)}/20',
          icon: Icons.score,
          color: analysis.moyenneGenerale >= 10 ? AppTheme.success : AppTheme.error,
        ),
        if (isIndiv)
          _buildKpiCard(
            title: 'Rang / Écart Classe',
            value: '${analysis.rang}er',
            subtitle: '${analysis.ecartVsClasse > 0 ? '+' : ''}${analysis.ecartVsClasse} pts',
            icon: Icons.leaderboard,
            color: AppTheme.primary,
          )
        else
          _buildKpiCard(
            title: 'Taux de Réussite',
            value: '${analysis.tauxReussite}%',
            icon: Icons.check_circle_outline,
            color: analysis.tauxReussite >= 50 ? AppTheme.success : AppTheme.error,
          ),
        _buildKpiCard(
          title: isIndiv ? 'Tendance' : 'Meilleure Note',
          value: isIndiv ? analysis.tendance.toUpperCase() : '${analysis.meilleureNote}/20',
          icon: isIndiv ? Icons.trending_up : Icons.star,
          color: AppTheme.accent,
        ),
        _buildKpiCard(
          title: isIndiv ? 'Taux de Réussite' : 'Pire Note',
          value: isIndiv ? '${analysis.tauxReussite}%' : '${analysis.pireNote}/20',
          icon: isIndiv ? Icons.pie_chart : Icons.warning_amber,
          color: isIndiv
              ? (analysis.tauxReussite >= 50 ? AppTheme.success : AppTheme.error)
              : AppTheme.error,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: subtitle.startsWith('-') ? AppTheme.error : AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Évolution des notes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedType.toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildConseilsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.psychology, color: AppTheme.accent),
            const SizedBox(width: 8),
            const Text(
              'Bilan Pédagogique IA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._noteAnalysis!.conseils.map((conseil) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ConseilCard(conseil: conseil),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNotesExamensList(Map<String, dynamic> notesExamens) {
    if (notesExamens.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Notes des Examens Blancs/Nationaux',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notesExamens.keys.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final typeExamen = notesExamens.keys.elementAt(index);
            final notes = notesExamens[typeExamen] as List<dynamic>;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeExamen,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                    const Divider(),
                    ...notes.map((noteData) {
                      final nom = noteData['eleve_nom'] ?? 'Inconnu';
                      final matiere = noteData['matiere'] ?? '';
                      final valeur = double.tryParse(noteData['valeur'].toString());

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$nom - $matiere', style: const TextStyle(fontWeight: FontWeight.w500)),
                            if (valeur != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: valeur >= 10 ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$valeur/20',
                                  style: TextStyle(
                                    color: valeur >= 10 ? AppTheme.success : AppTheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList()
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
