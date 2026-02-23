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

  @override
  void initState() {
    super.initState();
    _selectedEleve = widget.initialEleve;
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

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
                    });
                  }
                },
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: apiService.getNotes(_selectedEleve.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                        ?.map((e) => (e as num).toDouble())
                        .toList() ??
                    [0.0, 0.0, 0.0];
                final moyenneGenerale =
                    (data['moyenne_generale'] as num?)?.toDouble() ?? 0.0;
                final recentNotes =
                    (data['recent_notes'] as List<dynamic>?) ?? [];

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
                      _buildAnalyseChart(progression),
                      const SizedBox(height: 24),

                      _buildConseilPedagogique(moyenneGenerale),
                      const SizedBox(height: 32),

                      Text(
                        'Dernières Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildNotesList(recentNotes),
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade100, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 2,
              minY: 0,
              maxY: 20,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, progression.isNotEmpty ? progression[0] : 0),
                    FlSpot(1, progression.length > 1 ? progression[1] : 0),
                    FlSpot(2, progression.length > 2 ? progression[2] : 0),
                  ],
                  isCurved: true,
                  color: AppTheme.accent, // Using Gold for the chart line
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: AppTheme.accent,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent.withValues(alpha: 0.2),
                        AppTheme.accent.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConseilPedagogique(double moyenneGenerale) {
    String conseil =
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

  Widget _buildNotesList(List<dynamic> recentNotes) {
    if (recentNotes.isEmpty) {
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
              'Aucune note récente disponible.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentNotes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final noteData = recentNotes[index];
        final note = (noteData['note'] as num).toDouble();
        final color = note >= 10 ? AppTheme.success : AppTheme.error;

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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppTheme.primary,
              ),
            ),
            title: Text(
              noteData['matiere'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${noteData['type']} • ${noteData['date']}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${note.toStringAsFixed(1)}/20',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
