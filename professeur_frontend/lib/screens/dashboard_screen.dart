import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/professeur.dart';
import '../models/dashboard_stats.dart';
import '../models/classe.dart';
import '../models/moyenne.dart';
import '../widgets/classe_card.dart';
import '../widgets/moyenne_table.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/quick_action_card.dart';
import '../utils/theme.dart';
import 'notes_screen.dart';
import 'cahier_texte_screen.dart';
import 'presences_screen.dart';
import 'exercices_non_faits_screen.dart';
import 'package:intl/intl.dart';
import '../models/communique.dart';
import '../models/evenement.dart';
import '../widgets/communique_card.dart';
import '../widgets/event_card.dart';
import 'parent_contact_screen.dart';
import '../widgets/modern_dashboard_header.dart';
import '../widgets/premium_stat_card.dart';
import 'change_code_screen.dart';
import 'conduites_screen.dart';
import 'emploi_du_temps_screen.dart';
import 'paiements_screen.dart';
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Modern Header with Settings integrated
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

                        // Negative offset to pull stats up over the header slightly
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              child: PremiumStatCard(
                                label: 'Heures Effectuées',
                                value: '${_stats.coursSemaine}h',
                                icon: Icons.access_time_filled,
                                baseColor: const Color(0xFF8B5CF6), // Violet 500
                                subLabel: 'Cette semaine',
                              ),
                            ),
                          ),
                        ),

                        // Section Spacing adjustment after overlap
                        const SizedBox(height: 16),

                        // Emploi du Temps Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Emploi du temps d'aujourd'hui",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTodaySchedule(),
                        const SizedBox(height: 40),

                        // Quick Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Accès Rapide',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              QuickActionCard(
                                title: 'Saisir\nNotes',
                                icon: Icons.edit_note,
                                color: AppTheme.secondary,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotesScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Cahier\nde Texte',
                                icon: Icons.menu_book,
                                color: AppTheme.primary,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CahierTexteScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Faire\nl\'Appel',
                                icon: Icons.fact_check_outlined,
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PresencesScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Emploi du\nTemps',
                                icon: Icons.schedule,
                                color: Colors.indigo,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EmploiDuTempsScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Note de\nConduite',
                                icon: Icons.assignment_ind_outlined,
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConduitesScreen(classes: _classes)),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Contacts\nParents',
                                icon: Icons.contact_phone_outlined,
                                color: AppTheme.accent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ParentContactScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Mes\nPaiements',
                                icon: Icons.payments_outlined,
                                color:
                                    Colors.green, // Dedicated color for payroll
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PaiementsScreen()),
                                  );
                                },
                              ),
                              QuickActionCard(
                                title: 'Devoirs\nNon Faits',
                                icon: Icons.assignment_late_outlined,
                                color: Colors.redAccent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ExercicesNonFaitsScreen(classes: _classes)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Agenda Section
                        if (_evenements.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Agenda',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // TextButton(
                                //   onPressed: () {},
                                //   child: const Text('Tout voir'),
                                // ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 130, // Slightly more space for event cards
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 4),
                              itemCount: _evenements.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: EventCard(
                                    event: _evenements[index],
                                    isFeatured: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],

                        // Communiques Section
                        if (_communiques.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Actualités',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _communiques.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CommuniqueCard(
                                  communique: _communiques[index],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Mes Classes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Mes Classes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _classes.isEmpty
                            ? Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 32, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.class_outlined,
                                          size: 48, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'Aucune classe assignée',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height:
                                    210, // Adjusted for typical content height
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 4),
                                  itemCount: _classes.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 280, // Slightly wider class card
                                      margin: const EdgeInsets.only(right: 16),
                                      child:
                                          ClasseCard(classe: _classes[index]),
                                    );
                                  },
                                ),
                              ),

                        const SizedBox(height: 40),

                        // Moyennes Section (Simple Card wrapper for existing table)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consultation Rapide',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              initialValue: _selectedClasseId,
                                              items: [
                                                const DropdownMenuItem(
                                                  value: 0,
                                                  child: Text(
                                                      'Choisir une classe',
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                ),
                                                ..._classes.map(
                                                  (classe) => DropdownMenuItem(
                                                    value: classe.id,
                                                    child: Text(
                                                      classe.displayName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: _onClasseSelected,
                                              decoration: const InputDecoration(
                                                labelText: 'Classe',
                                              ),
                                              icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color:
                                                      AppTheme.textSecondary),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              initialValue: _selectedTrimestre,
                                              items: [1, 2, 3]
                                                  .map(
                                                    (trimestre) =>
                                                        DropdownMenuItem(
                                                      value: trimestre,
                                                      child: Text(
                                                          'Trimestre $trimestre',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: _onTrimestreSelected,
                                              decoration: const InputDecoration(
                                                labelText: 'Trimestre',
                                              ),
                                              icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color:
                                                      AppTheme.textSecondary),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Résultats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          if (_selectedClasseId > 0 && _moyennes.isNotEmpty)
                                            ElevatedButton.icon(
                                              onPressed: _downloadAveragesPdf,
                                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                                              label: const Text('Télécharger en PDF'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (_loadingMoyennes)
                                        const Center(
                                            child: Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: CircularProgressIndicator(),
                                        ))
                                      else if (_selectedClasseId > 0 &&
                                          _moyennes.isNotEmpty)
                                        MoyenneTable(moyennes: _moyennes)
                                      else
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32.0),
                                            child: Column(
                                              children: [
                                                Icon(Icons.analytics_outlined,
                                                    size: 48,
                                                    color:
                                                        Colors.grey.shade300),
                                                const SizedBox(height: 16),
                                                Text(
                                                  _selectedClasseId == 0
                                                      ? 'Sélectionnez une classe pour voir les moyennes'
                                                      : 'Aucune donnée disponible',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  // --- Helper Methods ---

  Widget _buildTodaySchedule() {
    if (_loadingSchedule) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_todaySchedule.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text('Aucun cours aujourd\'hui', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }
    
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _todaySchedule.length,
        itemBuilder: (context, index) {
          final slot = _todaySchedule[index];
          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.white]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.shade100),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: Colors.indigo.shade400),
                    const SizedBox(width: 8),
                    Text('${slot.heureDebut.substring(0, 5)} - ${slot.heureFin.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
                const Spacer(),
                Text(slot.classe?['nom'] ?? 'Classe', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(slot.matiere?['nom'] ?? 'Matière', style: TextStyle(color: Colors.grey.shade700)),
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
        moyennes: _moyennes,
        classeName: classeName,
        matiereName: _professeur.matiere,
        trimestre: _selectedTrimestre,
        profName: '${_professeur.firstName} ${_professeur.lastName}',
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document généré avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.grey,
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
