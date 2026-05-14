import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emploi_du_temps.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  const EmploiDuTempsScreen({super.key});

  @override
  _EmploiDuTempsScreenState createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen>
    with SingleTickerProviderStateMixin {
  List<EmploiDuTemps> _slots = [];
  bool _isLoading = true;
  String _error = '';
  late TabController _tabController;

  final List<String> _jours = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'
  ];

  // Couleurs par jour (pour les chips)
  final List<Color> _jourColors = [
    const Color(0xFF3B82F6), // Bleu
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF10B981), // Vert
    const Color(0xFFF59E0B), // Ambre
    const Color(0xFFEF4444), // Rouge
    const Color(0xFF0EA5E9), // Bleu ciel
  ];

  @override
  void initState() {
    super.initState();
    final int currentWeekday = DateTime.now().weekday;
    final int initialIndex =
        (currentWeekday >= 1 && currentWeekday <= 6) ? currentWeekday - 1 : 0;
    _tabController =
        TabController(length: _jours.length, vsync: this, initialIndex: initialIndex);
    _loadEmploiDuTemps();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEmploiDuTemps() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final slots = await apiService.getEmploiDuTemps();
      setState(() { _slots = slots; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Map<String, List<EmploiDuTemps>> _groupByDay() {
    final grouped = <String, List<EmploiDuTemps>>{
      for (var j in _jours) j: [],
    };
    for (var slot in _slots) {
      for (var key in grouped.keys) {
        if (key.toLowerCase() == slot.jour.toLowerCase()) {
          grouped[key]!.add(slot);
          break;
        }
      }
    }
    // Trier par heure de début
    for (var list in grouped.values) {
      list.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: PremiumAppBar(
        title: 'Emploi du Temps',
        subtitle: 'Semaine en cours',
        actions: [
          PremiumActionBtn(
            icon: Icons.refresh_rounded,
            onTap: _loadEmploiDuTemps,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2))
          : _error.isNotEmpty
              ? _buildError()
              : Column(
                  children: [
                    // TabBar premium
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _jours.asMap().entries.map((entry) {
                          final index = entry.key;
                          final jour = entry.value;
                          final jourSlots = _groupByDay()[jour] ?? [];
                          return _buildDayView(jour, jourSlots, _jourColors[index]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0D1B3E),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppTheme.gold.withOpacity(0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400, fontSize: 13),
        tabs: _jours.asMap().entries.map((entry) {
          final slotsCount = (_groupByDay()[entry.value] ?? []).length;
          return Tab(
            child: Row(
              children: [
                Text(entry.value),
                if (slotsCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _jourColors[entry.key],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$slotsCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayView(String jour, List<EmploiDuTemps> slots, Color color) {
    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.beach_access_rounded,
                  size: 48, color: color.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              'Journée libre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aucun cours prévu ce $jour',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmploiDuTemps,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        itemCount: slots.length,
        itemBuilder: (context, index) => _buildSlotCard(slots[index], color, index),
      ),
    );
  }

  Widget _buildSlotCard(EmploiDuTemps slot, Color color, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Barre colorée gauche + horaire
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.heureDebut.length >= 5
                      ? slot.heureDebut.substring(0, 5)
                      : slot.heureDebut,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                Container(
                  width: 24,
                  height: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: color.withOpacity(0.3),
                ),
                Text(
                  slot.heureFin.length >= 5
                      ? slot.heureFin.substring(0, 5)
                      : slot.heureFin,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Classe
                  Text(
                    slot.classe?['nom'] ?? 'Classe inconnue',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Matière
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.menu_book_rounded,
                            size: 14, color: color),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          slot.matiere?['nom'] ?? 'Matière inconnue',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Salle
                  if (slot.salle != null && slot.salle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.bgMedium,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.room_rounded,
                              size: 14, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Salle ${slot.salle}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Numéro de cours
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppTheme.error),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger l\'emploi du temps',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(_error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEmploiDuTemps,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
