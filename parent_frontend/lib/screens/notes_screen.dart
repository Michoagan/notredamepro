import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../widgets/enfant_selector.dart';

class NotesScreen extends StatefulWidget {
  final List<Eleve> enfants;
  final Eleve initialEleve;

  const NotesScreen({
    super.key,
    required this.enfants,
    required this.initialEleve,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Eleve _selectedEleve;
  String _selectedMatiere = 'Vue Générale';
  Future<Map<String, dynamic>?>? _notesFuture;

  @override
  void initState() {
    super.initState();
    _selectedEleve = widget.initialEleve;
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotes();
    });
  }

  void _fetchNotes() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _notesFuture = apiService.getNotes(_selectedEleve.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Rendement Scolaire', style: TextStyle(fontSize: 16)),
            Text(
              _selectedEleve.prenom,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          if (widget.enfants.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              child: EnfantSelectorWidget(
                enfants: widget.enfants,
                selectedEnfant: _selectedEleve,
                onEnfantSelected: (enfant) {
                  if (_selectedEleve.id != enfant.id) {
                    setState(() {
                      _selectedEleve = enfant;
                      _selectedMatiere = 'Vue Générale'; // Réinitialiser le filtre
                      _fetchNotes(); // Recharger uniquement lors du changement d'enfant
                    });
                  }
                },
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _notesFuture == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Impossible de charger les notes.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                final progression =
                    (data['progression'] as List<dynamic>?)
                        ?.map(
                          (e) => double.tryParse(e?.toString() ?? '') ?? 0.0,
                        )
                        .toList() ??
                    [0.0, 0.0, 0.0];
                final moyenneGenerale =
                    double.tryParse(
                      data['moyenne_generale']?.toString() ?? '',
                    ) ??
                    0.0;
                final notesParTrimestre =
                    (data['notes_par_trimestre'] as List<dynamic>?) ?? [];

                final performancesMatieres =
                    (data['performances_matieres'] as List<dynamic>?) ?? [];

                // Extraire la liste des matières pour le sélecteur
                List<String> matieresAvailable = ['Vue Générale'];
                for (var perf in performancesMatieres) {
                  matieresAvailable.add(perf['matiere'] as String);
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard(context, moyenneGenerale),
                      const SizedBox(height: 32),

                      Text(
                        'Analyse de Progression',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sélecteur de matière
                      if (matieresAvailable.length > 1)
                        _buildMatiereSelector(matieresAvailable),

                      const SizedBox(height: 16),

                      // Affichage dynamique du graphique
                      _selectedMatiere == 'Vue Générale'
                          ? _buildAnalyseChart(progression)
                          : _buildMatiereChart(
                              performancesMatieres.firstWhere(
                                (p) => p['matiere'] == _selectedMatiere,
                                orElse: () => performancesMatieres.first,
                              ),
                            ),

                      const SizedBox(height: 24),

                      _buildConseilPedagogique(
                        moyenneGenerale,
                        performancesMatieres,
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Notes par Trimestre',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTrimestresList(notesParTrimestre),
                      const SizedBox(height: 40),

                      Text(
                        'Notes des Examens',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildNotesExamensList(
                        (data['notes_examens'] is Map)
                            ? Map<String, dynamic>.from(
                                data['notes_examens'] as Map,
                              )
                            : {},
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, double moyenneGenerale) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Moyenne Générale',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '(Trimestre en cours)',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${moyenneGenerale.toStringAsFixed(2)} / 20',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatiereSelector(List<String> matieres) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: matieres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final matiere = matieres[index];
          final isSelected = _selectedMatiere == matiere;

          return ActionChip(
            label: Text(
              matiere,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            backgroundColor: isSelected
                ? AppTheme.primary
                : AppTheme.background,
            side: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onPressed: () {
              setState(() {
                _selectedMatiere = matiere;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildAnalyseChart(List<double> progression) {
    if (progression.isEmpty) progression = [0, 0, 0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('T1', style: style);
                          break;
                        case 1:
                          text = const Text('T2', style: style);
                          break;
                        case 2:
                          text = const Text('T3', style: style);
                          break;
                        default:
                          text = const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: text,
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: 5,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                },
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: progression.isNotEmpty ? progression[0] : 0,
                      color: AppTheme.accent,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: progression.length > 1 ? progression[1] : 0,
                      color: AppTheme.accent,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: progression.length > 2 ? progression[2] : 0,
                      color: AppTheme.accent,
                      width: 22,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatiereChart(Map<String, dynamic> perfData) {
    double interros = 0.0, devoirs = 0.0, moyenne = 0.0;

    if (perfData['moyenne_interros'] != null) {
      interros =
          double.tryParse(perfData['moyenne_interros'].toString()) ?? 0.0;
    }
    if (perfData['moyenne_devoirs'] != null) {
      devoirs = double.tryParse(perfData['moyenne_devoirs'].toString()) ?? 0.0;
    }
    if (perfData['moyenne_trimestrielle'] != null) {
      moyenne =
          double.tryParse(perfData['moyenne_trimestrielle'].toString()) ?? 0.0;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Interros';
                          break;
                        case 1:
                          text = 'Devoirs';
                          break;
                        case 2:
                          text = 'Moyenne';
                          break;
                        default:
                          text = '';
                          break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 5,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade100,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: interros,
                      color: AppTheme.warning,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: devoirs,
                      color: AppTheme.primaryLight,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: moyenne,
                      color: AppTheme.success,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConseilPedagogique(
    double moyenneGenerale,
    List<dynamic> performancesMatieres,
  ) {
    String conseil = '';

    if (_selectedMatiere == 'Vue Générale') {
      conseil =
          'Continuez ainsi, le travail portera ses fruits. N\'hésitez pas à revoir les leçons le soir.';
      if (moyenneGenerale >= 16) {
        conseil =
            'Excellents résultats ! L\'investissement et le sérieux sont à féliciter.';
      } else if (moyenneGenerale >= 12) {
        conseil =
            'Bon ensemble. Les bases sont acquises. Poursuivez vos efforts pour atteindre l\'excellence.';
      } else if (moyenneGenerale < 10 && moyenneGenerale > 0) {
        conseil =
            'Des résultats insuffisants, une implication plus rigoureuse dans le travail personnel est attendue. Le corps professoral est à votre écoute.';
      } else if (moyenneGenerale == 0) {
        conseil = 'Les évaluations n\'ont pas encore été enregistrées.';
      }
    } else {
      final perfData = performancesMatieres.firstWhere(
        (p) => p['matiere'] == _selectedMatiere,
        orElse: () => null,
      );

      if (perfData != null) {
        double interros = 0.0, devoirs = 0.0, moyenne = 0.0;
        if (perfData['moyenne_interros'] != null) {
          interros =
              double.tryParse(perfData['moyenne_interros'].toString()) ?? 0.0;
        }
        if (perfData['moyenne_devoirs'] != null) {
          devoirs =
              double.tryParse(perfData['moyenne_devoirs'].toString()) ?? 0.0;
        }
        if (perfData['moyenne_trimestrielle'] != null) {
          moyenne =
              double.tryParse(perfData['moyenne_trimestrielle'].toString()) ??
              0.0;
        }

        if (moyenne == 0) {
          conseil =
              'Pas encore assez de notes pour une analyse détaillée en $_selectedMatiere.';
        } else if (moyenne >= 16) {
          conseil =
              'Très bon niveau en $_selectedMatiere. Le travail est régulier et approfondi !';
        } else if (moyenne >= 12) {
          if (interros > (devoirs + 2)) {
            conseil =
                'Bons résultats. Les leçons sont maîtrisées (bonnes interros), cependant l\'approfondissement lors des devoirs sur table peut être amélioré.';
          } else if (devoirs > (interros + 2)) {
            conseil =
                'Bonne réflexion globale (bons devoirs), mais l\'apprentissage régulier des leçons devrait être renforcé pour assurer de meilleures notes en interrogation.';
          } else {
            conseil =
                'Niveau satisfaisant et régulier en $_selectedMatiere. Maintenez le cap !';
          }
        } else {
          if (interros < 10 && devoirs >= 10) {
            conseil =
                'Apprenez vos leçons plus régulièrement. La compréhension est là (devoirs corrects), mais l\'apprentissage du cours fait défaut.';
          } else if (devoirs < 10 && interros >= 10) {
            conseil =
                'Les cours sont sus, mais l\'application lors des devoirs reste fragile. Privilégiez l\'entraînement avec des exercices pratiques.';
          } else {
            conseil =
                'Des difficultés persistantes en $_selectedMatiere. Un accompagnement régulier ou des révisions ciblées sont vivement recommandés.';
          }
        }
      } else {
        conseil = 'Données non disponibles pour cette matière.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conseil du Professeur Principal',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  conseil,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimestresList(List<dynamic> trimestres) {
    if (trimestres.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune note n\'a été enregistrée pour le moment.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trimestres.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final trimestreData = trimestres[index];
        final numTrimestre = trimestreData['trimestre'];
        final moyenneTrimestrielle =
            double.tryParse(
              trimestreData['moyenne_trimestrielle']?.toString() ?? '',
            ) ??
            0.0;

        final matieres = (trimestreData['matieres'] as List<dynamic>?) ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppTheme.primaryDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trimestre $numTrimestre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      fontSize: 16,
                    ),
                  ),
                  if (moyenneTrimestrielle > 0) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: moyenneTrimestrielle >= 10
                            ? AppTheme.success.withValues(alpha: 0.1)
                            : AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Moy: ${moyenneTrimestrielle.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: moyenneTrimestrielle >= 10
                              ? AppTheme.success
                              : AppTheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: matieres.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final m = matieres[idx];
                final matiere = m['matiere'] as String;
                final moyenneMatiere = m['moyenne'] != null
                    ? double.tryParse(m['moyenne'].toString())
                    : null;

                final interros = (m['interros'] as List<dynamic>?) ?? [];
                final devoirs = (m['devoirs'] as List<dynamic>?) ?? [];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        matiere,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: m['professeur'] != null
                          ? Text(
                              'Prof: ${m['professeur']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            )
                          : null,
                      trailing: moyenneMatiere != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: moyenneMatiere >= 10
                                    ? AppTheme.success.withValues(alpha: 0.1)
                                    : AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                moyenneMatiere.toStringAsFixed(2),
                                style: TextStyle(
                                  color: moyenneMatiere >= 10
                                      ? AppTheme.success
                                      : AppTheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      children: [
                        if (interros.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Interros:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: interros.map<Widget>((noteData) {
                                    if (noteData == null)
                                      return const SizedBox();
                                    final val =
                                        double.tryParse(
                                          noteData['valeur']?.toString() ?? '',
                                        ) ??
                                        0.0;
                                    final bool isValidated =
                                        (noteData['is_validated'] == 1 ||
                                        noteData['is_validated'] == true);
                                    return _buildSmallNoteBadge(
                                      val,
                                      isValidated: isValidated,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (devoirs.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Devoirs :',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: devoirs.map<Widget>((noteData) {
                                    if (noteData == null)
                                      return const SizedBox();
                                    final val =
                                        double.tryParse(
                                          noteData['valeur']?.toString() ?? '',
                                        ) ??
                                        0.0;
                                    final bool isValidated =
                                        (noteData['is_validated'] == 1 ||
                                        noteData['is_validated'] == true);
                                    return _buildSmallNoteBadge(
                                      val,
                                      isDevoir: true,
                                      isValidated: isValidated,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (interros.isEmpty && devoirs.isEmpty)
                          const Text(
                            'Aucun détail d\'évaluation disponible.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallNoteBadge(
    double note, {
    bool isDevoir = false,
    bool isValidated = true,
  }) {
    final color = note >= 10 ? AppTheme.success : AppTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDevoir
            ? AppTheme.primaryLight.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDevoir
              ? AppTheme.primaryLight.withValues(alpha: 0.3)
              : AppTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            note.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (!isValidated) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.access_time_filled_rounded,
              size: 10,
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesExamensList(Map<String, dynamic> notesExamens) {
    if (notesExamens.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.assignment_turned_in_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune note d\'examen n\'a été enregistrée pour le moment.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notesExamens.keys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final typeExamen = notesExamens.keys.elementAt(index);
        final notes = notesExamens[typeExamen] as List<dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    typeExamen,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final noteData = notes[idx];
                final matiere = noteData['matiere'] as String;
                final valeur = double.tryParse(noteData['valeur'].toString());
                final annee = noteData['annee_scolaire'] ?? '';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            matiere,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (annee.isNotEmpty)
                            Text(
                              annee,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      if (valeur != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: valeur >= 10
                                ? AppTheme.success.withValues(alpha: 0.1)
                                : AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$valeur / 20',
                            style: TextStyle(
                              color: valeur >= 10
                                  ? AppTheme.success
                                  : AppTheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
