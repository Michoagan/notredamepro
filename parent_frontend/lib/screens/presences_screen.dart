import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../widgets/enfant_selector.dart';

class PresencesScreen extends StatefulWidget {
  final List<Eleve> enfants;
  final Eleve initialEleve;

  const PresencesScreen({
    super.key,
    required this.enfants,
    required this.initialEleve,
  });

  @override
  State<PresencesScreen> createState() => _PresencesScreenState();
}

class _PresencesScreenState extends State<PresencesScreen> {
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
            const Text('Présences', style: TextStyle(fontSize: 16)),
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
              future: apiService.getPresences(_selectedEleve.id),
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
                          'Impossible de charger les présences.',
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
                final tauxPresence =
                    (data['taux_presence'] as num?)?.toDouble() ?? 100.0;
                final presences = (data['presences'] as List<dynamic>?) ?? [];

                int absencesCount = 0;
                for (var p in presences) {
                  if (p['present'] == false || p['present'] == 0)
                    absencesCount++;
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
                      _buildStatSummary(tauxPresence, absencesCount),
                      const SizedBox(height: 32),

                      Text(
                        'Historique (30 derniers jours)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoriqueList(presences),
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

  Widget _buildStatSummary(double tauxPresence, int absencesCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            title: 'Taux Présence',
            value: '${tauxPresence.toStringAsFixed(1)}%',
            icon: Icons.check_circle_outline_rounded,
            color: tauxPresence > 80 ? AppTheme.success : AppTheme.warning,
            isGradient: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatBox(
            title: 'Absences',
            value: absencesCount.toString(),
            icon: Icons.person_off_rounded,
            color: absencesCount > 0 ? AppTheme.error : AppTheme.success,
            isGradient: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isGradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isGradient ? null : Colors.white,
        gradient: isGradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryLight],
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isGradient ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGradient ? AppTheme.primary : color).withValues(
              alpha: 0.15,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGradient
                  ? Colors.white.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isGradient ? Colors.white : color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isGradient ? Colors.white : color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isGradient ? Colors.white70 : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueList(List<dynamic> historique) {
    if (historique.isEmpty) {
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
              Icons.history_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune présence enregistrée.',
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
      itemCount: historique.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = historique[index];
        final isPresent = item['present'] == true || item['present'] == 1;
        final color = !isPresent ? AppTheme.error : AppTheme.success;
        final icon = !isPresent
            ? Icons.person_off_rounded
            : Icons.how_to_reg_rounded;
        final statut = !isPresent ? 'Absent' : 'Présent';
        final motif = item['motif'] ?? '';
        final date = item['date'] ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                item['matiere'] ?? motif,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                statut,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
