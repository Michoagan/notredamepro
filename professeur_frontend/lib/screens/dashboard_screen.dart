import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/professeur.dart';
import '../models/dashboard_stats.dart';
import '../models/classe.dart';
import '../models/moyenne.dart';
import '../widgets/moyenne_table.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/quick_action_card.dart';
import '../utils/theme.dart';
import 'notes_screen.dart';
import 'cahier_texte_screen.dart';
import 'presences_screen.dart';
import 'exercices_non_faits_screen.dart';
import '../models/communique.dart';
import '../models/evenement.dart';
import '../widgets/communique_card.dart';
import '../widgets/event_card.dart';
import 'parent_contact_screen.dart';
import '../widgets/modern_dashboard_header.dart';
import 'change_code_screen.dart';
import 'conduites_screen.dart';
import 'emploi_du_temps_screen.dart';
import 'salaires_screen.dart';
import '../models/emploi_du_temps.dart';
import '../services/pdf_service.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Professeur _professeur;
  late DashboardStats _stats;
  late List<Classe> _classes;
  List<Communique> _communiques = [];
  List<Evenement> _evenements = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedClasseId = 0;
  int _selectedTrimestre = 1;
  List<Moyenne> _moyennes = [];
  bool _loadingMoyennes = false;

  int _selectedIndex = 0;
  List<EmploiDuTemps> _todaySchedule = [];
  bool _loadingSchedule = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _initPushNotifications();
  }

  void _initPushNotifications() {
    final notificationService = NotificationService();
    notificationService.initNotifications((token) async {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.sendFcmToken(token);
        debugPrint('FCM Token envoyé au serveur avec succès.');
      } catch (e) {
        debugPrint('Erreur lors de l\'envoi du FCM Token: $e');
      }
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.getDashboardData();

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _professeur = result['professeur'];
            _stats = result['stats'];
            _classes = result['classes'] ?? [];
            _communiques = result['communiques'] ?? [];
            _evenements = result['evenements'] ?? [];
            _isLoading = false;
            _errorMessage = '';
          });
          _loadTodaySchedule();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage =
                result['message'] ?? 'Erreur de chargement des données';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur de connexion: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadTodaySchedule() async {
    setState(() { _loadingSchedule = true; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final slots = await apiService.getEmploiDuTemps();
      final jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      String todayStr = 'Lundi'; // Default fallback
      if (DateTime.now().weekday >= 1 && DateTime.now().weekday <= 7) {
        todayStr = jours[DateTime.now().weekday - 1];
      }
      
      if (mounted) {
        setState(() {
          _todaySchedule = slots.where((s) => s.jour == todayStr).toList();
          _todaySchedule.sort((a, b) => a.heureDebut.compareTo(b.heureDebut));
          _loadingSchedule = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loadingSchedule = false; });
    }
  }

  Future<void> _loadMoyennes() async {
    if (_selectedClasseId == 0) return;

    setState(() {
      _loadingMoyennes = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final moyennes = await apiService.calculerMoyennes(
        classeId: _selectedClasseId,
        trimestre: _selectedTrimestre,
        matiereId: _professeur.matiereId,
      );

      if (mounted) {
        setState(() {
          _moyennes = moyennes;
          _loadingMoyennes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingMoyennes = false;
          _moyennes = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Erreur lors du chargement des moyennes: ${e.toString()}')));
      }
    }
  }

  void _onClasseSelected(int? value) {
    if (value != null) {
      setState(() {
        _selectedClasseId = value;
      });
      _loadMoyennes();
    }
  }

  void _onTrimestreSelected(int? value) {
    if (value != null) {
      setState(() {
        _selectedTrimestre = value;
      });
      _loadMoyennes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: _isLoading ? null : CustomDrawer(professeur: _professeur),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                            fontSize: 16, color: AppTheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  color: const Color(0xFF1A237E),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header premium
                        ModernDashboardHeader(
                          professeur: _professeur,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          onSettingsPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ChangeCodeScreen()),
                            );
                          },
                          onNotificationPressed: () {
                            // Show notifications
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Aucune nouvelle notification')),
                            );
                          },
                        ),

                        // 2. KPI Stats Row
                        _buildKpiRow(),

                        const SizedBox(height: 28),

                        // 3. Emploi du temps
                        _buildSectionHeader(context, 'Cours d\'aujourd\'hui', Icons.schedule_rounded),
                        const SizedBox(height: 14),
                        _buildTodaySchedule(),
                        const SizedBox(height: 28),

                        // 4. Accès Rapide
                        _buildSectionHeader(context, 'Accès Rapide', Icons.grid_view_rounded),
                        const SizedBox(height: 14),
                        _buildQuickActions(),
                        const SizedBox(height: 28),

                        // 5. Mes Classes
                        _buildSectionHeader(context, 'Mes Classes', Icons.class_rounded),
                        const SizedBox(height: 14),
                        _buildClassesSection(),
                        const SizedBox(height: 28),

                        // 6. Agenda
                        if (_evenements.isNotEmpty) ...[
                          _buildSectionHeader(context, 'Agenda', Icons.event_rounded),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _evenements.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: EventCard(event: _evenements[index], isFeatured: true),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // 7. Actualités
                        if (_communiques.isNotEmpty) ...[
                          _buildSectionHeader(context, 'Actualités', Icons.campaign_rounded),
                          const SizedBox(height: 14),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _communiques.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CommuniqueCard(communique: _communiques[index]),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // 8. Consultation Moyennes
                        _buildSectionHeader(context, 'Consultation Rapide', Icons.analytics_rounded),
                        const SizedBox(height: 14),
                        _buildMoyennesCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }


  // ═══════════════════════════════════════════════════════════
  //  NEW PREMIUM HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withAlpha(30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    final kpis = [
      _KpiData('Classes', '${_classes.length}', Icons.class_rounded, const Color(0xFF3B82F6)),
      _KpiData('Cours/sem.', '${_stats.coursSemaine}h', Icons.access_time_filled, const Color(0xFF8B5CF6)),
      _KpiData('Élèves', '${_stats.elevesCount}', Icons.people_rounded, const Color(0xFF10B981)),
      _KpiData('Trimestre', 'T$_selectedTrimestre', Icons.bar_chart_rounded, const Color(0xFFF59E0B)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: kpis.asMap().entries.map((e) {
          final kpi = e.value;
          return Container(
            margin: EdgeInsets.only(right: e.key < kpis.length - 1 ? 12 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kpi.color.withAlpha(30)),
              boxShadow: [
                BoxShadow(
                  color: kpi.color.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kpi.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(kpi.icon, color: kpi.color, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kpi.value, style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900, color: kpi.color,
                    )),
                    Text(kpi.label, style: const TextStyle(
                      fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500,
                    )),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionData('Saisir Notes', Icons.edit_note_rounded, const Color(0xFF10B981), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()))),
      _ActionData('Faire l\'Appel', Icons.fact_check_rounded, const Color(0xFFF97316), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresencesScreen()))),
      _ActionData('Cahier de Texte', Icons.menu_book_rounded, const Color(0xFF1A237E), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CahierTexteScreen()))),
      _ActionData('Emploi du Temps', Icons.calendar_month_rounded, const Color(0xFF6366F1), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmploiDuTempsScreen()))),
      _ActionData('Note de Conduite', Icons.assignment_ind_rounded, const Color(0xFF14B8A6), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConduitesScreen(classes: _classes)))),
      _ActionData('Contacts Parents', Icons.contact_phone_rounded, const Color(0xFFF59E0B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentContactScreen()))),
      _ActionData('Mes Paiements', Icons.account_balance_wallet_rounded, const Color(0xFF22C55E), () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalairesScreen()))),
      _ActionData('Devoirs Non Faits', Icons.assignment_late_rounded, const Color(0xFFEF4444), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExercicesNonFaitsScreen(classes: _classes)))),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate((actions.length / 2).ceil(), (rowIdx) {
          final left = actions[rowIdx * 2];
          final rightIdx = rowIdx * 2 + 1;
          final right = rightIdx < actions.length ? actions[rightIdx] : null;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: QuickActionCard(title: left.title, icon: left.icon, color: left.color, onTap: left.onTap)),
                const SizedBox(width: 12),
                right != null
                    ? Expanded(child: QuickActionCard(title: right.title, icon: right.icon, color: right.color, onTap: right.onTap))
                    : const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClassesSection() {
    if (_classes.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Column(children: [
            Icon(Icons.class_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Aucune classe assignée', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final classe = _classes[index];
          final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
          final color = colors[index % colors.length];
          return GestureDetector(
            onTap: () { setState(() { _selectedClasseId = classe.id; }); _loadMoyennes(); },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: color.withAlpha(60), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.class_rounded, color: Colors.white, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(classe.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15), overflow: TextOverflow.ellipsis),
                      Text('Appuyer pour voir', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoyennesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _selectedClasseId == 0 ? null : _selectedClasseId,
                  hint: const Text('Classe', style: TextStyle(fontSize: 13)),
                  items: _classes.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.displayName, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: _onClasseSelected,
                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppTheme.textSecondary),
                  decoration: const InputDecoration(labelText: 'Classe', isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _selectedTrimestre,
                  items: [1, 2, 3].map((t) => DropdownMenuItem(
                    value: t,
                    child: Text('Trim. $t', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: _onTrimestreSelected,
                  icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppTheme.textSecondary),
                  decoration: const InputDecoration(labelText: 'Trimestre', isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Résultats', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              if (_selectedClasseId > 0 && _moyennes.isNotEmpty)
                TextButton.icon(
                  onPressed: _downloadAveragesPdf,
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('PDF'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingMoyennes)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_selectedClasseId > 0 && _moyennes.isNotEmpty)
            MoyenneTable(moyennes: _moyennes)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.analytics_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      _selectedClasseId == 0 ? 'Sélectionnez une classe' : 'Aucune donnée disponible',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Existing helpers (preserved) ───────────────────────────

  Widget _buildTodaySchedule() {
    if (_loadingSchedule) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primary)));
    }
    if (_todaySchedule.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.beach_access_rounded, color: Colors.grey, size: 24)),
            const SizedBox(width: 16),
            const Text('Aucun cours aujourd\'hui', style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _todaySchedule.length,
        itemBuilder: (context, index) {
          final slot = _todaySchedule[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D1B3E), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withAlpha(60), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '${slot.heureDebut.length >= 5 ? slot.heureDebut.substring(0, 5) : slot.heureDebut} - ${slot.heureFin.length >= 5 ? slot.heureFin.substring(0, 5) : slot.heureFin}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Spacer(),
                Text(slot.classe?['nom'] ?? 'Classe', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(slot.matiere?['nom'] ?? 'Matière', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadAveragesPdf() async {
    try {
      final classeName = _classes.firstWhere((c) => c.id == _selectedClasseId).displayName;
      await PdfService.generateAndDownloadBulletin(
        moyennes: _moyennes, classeName: classeName,
        matiereName: _professeur.matiere, trimestre: _selectedTrimestre,
        profName: '${_professeur.firstName} ${_professeur.lastName}',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document généré avec succès')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() { _selectedIndex = index; });
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const EmploiDuTempsScreen())).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeCodeScreen())).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  Widget _buildModernBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B3E), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withAlpha(80), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white38,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Accueil'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Planning'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Paramètres'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────
class _KpiData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _ActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionData(this.title, this.icon, this.color, this.onTap);
}


