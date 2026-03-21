import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../models/eleve.dart';
import '../widgets/enfant_selector.dart';
import 'notes_screen.dart';
import 'presences_screen.dart';
import 'finances_screen.dart';
import 'communication_screen.dart';
import 'dart:async';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'emploi_du_temps_screen.dart';
import 'convocations_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _parentName = "Parent";
  List<Eleve> _mesEnfants = [];
  Eleve? _selectedEnfant;
  List<dynamic> _alertesScolarite = [];
  int _unreadNotifications = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadNotifications();

    // Polling every 30 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlertesScolarite() async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getAlertesScolarite();
    if (data != null && data['success'] == true && mounted) {
      setState(() {
        _alertesScolarite = data['alertes'] ?? [];
      });
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getNotifications();
    if (data != null && data['success'] == true && mounted) {
      final int newCount = data['unread_count'] ?? 0;
      if (newCount > _unreadNotifications && _unreadNotifications > 0) {
        // Show a local in-app notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous avez une nouvelle notification',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VOIR',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    )
                    .then((_) => _loadNotifications());
              },
            ),
          ),
        );
      }

      setState(() {
        _unreadNotifications = newCount;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getDashboardData();

    if (data != null && data['success'] == true) {
      final parentData = data['parent'];
      String parentName = "Parent";
      if (parentData != null) {
        parentName = "${parentData['prenom'] ?? ''} ${parentData['nom'] ?? ''}"
            .trim();
      }

      final List<dynamic> elevesJson = data['eleves'] ?? [];
      final loadedEleves = elevesJson.map((e) => Eleve.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _parentName = parentName.isEmpty ? "Parent" : parentName;
          _mesEnfants = loadedEleves;
          if (_mesEnfants.isNotEmpty) {
            _selectedEnfant = _mesEnfants.first;
          }
          _isLoading = false;
        });
        _loadAlertesScolarite();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Impossible de charger les données du tableau de bord',
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildAlerteBanner(dynamic alerte) {
    final nom = alerte['eleve_nom'] ?? '';
    final tranche = alerte['tranche_nom'] ?? '';
    final jours = alerte['jours_restants'] ?? 0;

    final daysText = jours == 0 ? "Aujourd'hui" : "dans $jours jour(s)";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerte Scolarité : $nom',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Le délai pour la $tranche est $daysText. Veuillez régulariser la situation.',
                  style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_alertesScolarite.isNotEmpty)
                          ..._alertesScolarite.map(
                            (alerte) => _buildAlerteBanner(alerte),
                          ),

                        // Enfant Selector Section
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                                child: Text(
                                  'Sélectionner un enfant',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: EnfantSelectorWidget(
                                  enfants: _mesEnfants,
                                  selectedEnfant: _selectedEnfant,
                                  onEnfantSelected: (enfant) {
                                    setState(() {
                                      _selectedEnfant = enfant;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        // Section d'actions
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedEnfant != null) ...[
                                Text(
                                  'Aperçu: ${_selectedEnfant!.prenom}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                ),
                                // Aperçu Premium
                                _buildPremiumOverviewCard(
                                  context,
                                  _selectedEnfant!,
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  'Détails Rapides',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.primaryDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                                const SizedBox(height: 16),

                                // Grille d'actions rapides (restylée)
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.1,
                                  children: [
                                    _buildActionCard(
                                      context,
                                      title: 'Rendement Scolaire',
                                      icon: Icons.auto_graph_rounded,
                                      color: AppTheme.primary,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NotesScreen(
                                              enfants: _mesEnfants,
                                              initialEleve: _selectedEnfant!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      context,
                                      title: 'Assiduité',
                                      icon: Icons.calendar_today_rounded,
                                      color: const Color(0xFFF59E0B), // Amber
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PresencesScreen(
                                              enfants: _mesEnfants,
                                              initialEleve: _selectedEnfant!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      context,
                                      title: 'Détails Financiers',
                                      icon:
                                          Icons.account_balance_wallet_rounded,
                                      color: AppTheme.success,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FinancesScreen(
                                              enfants: _mesEnfants,
                                              initialEleve: _selectedEnfant!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      context,
                                      title: 'Communiqués',
                                      icon: Icons.campaign_rounded,
                                      color: const Color(0xFF8B5CF6), // Purple
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CommunicationScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      context,
                                      title: 'Emploi du Temps',
                                      icon: Icons.schedule_rounded,
                                      color: Colors.indigo,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EmploiDuTempsScreen(
                                              eleve: _selectedEnfant!.toJson(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildActionCard(
                                      context,
                                      title: 'Convocations & Devoirs',
                                      icon: Icons.assignment_turned_in_rounded,
                                      color: Colors.teal,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ConvocationsScreen(
                                              enfants: _mesEnfants,
                                              initialEleve: _selectedEnfant!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                              ] else ...[
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.person_off_rounded,
                                          size: 64,
                                          color: AppTheme.textSecondary,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Aucun enfant associé à ce compte.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        image: DecorationImage(
          image: AssetImage(
            'assets/images/logo.png',
          ), // Add slight opacity to logo in background
          fit: BoxFit.cover,
          alignment: Alignment(1.5, -0.5),
          opacity: 0.05,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _parentName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      )
                      .then((_) {
                        // Recharger après fermeture de l'écran des notifications
                        _loadNotifications();
                      });
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadNotifications > 9
                          ? '9+'
                          : _unreadNotifications.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 28,
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) async {
              if (value == 'password') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              } else if (value == 'logout') {
                final apiService = Provider.of<ApiService>(
                  context,
                  listen: false,
                );
                await apiService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'password',
                child: Row(
                  children: const [
                    Icon(
                      Icons.vpn_key_outlined,
                      size: 20,
                      color: AppTheme.textPrimary,
                    ),
                    SizedBox(width: 12),
                    Text('Changer le mot de passe'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded, size: 20, color: AppTheme.error),
                    SizedBox(width: 12),
                    Text(
                      'Déconnexion',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shadowColor: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withValues(alpha: 0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOverviewCard(BuildContext context, Eleve eleve) {
    final double tauxPresence = eleve.tauxPresence ?? 100.0;
    final double solde = eleve.soldeRestant ?? 0.0;
    final bool hasNotes =
        eleve.recentNotes != null && eleve.recentNotes!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          // En-tête de carte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Aperçu Global",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    eleve.classeName,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne de gauche (Assiduité & Finances)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Assiduité
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.how_to_reg_rounded,
                              color: AppTheme.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assiduité',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${tauxPresence.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Finances
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  (solde > 0
                                          ? AppTheme.warning
                                          : AppTheme.success)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: solde > 0
                                  ? AppTheme.warning
                                  : AppTheme.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reste à payer',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${solde.toStringAsFixed(0)} F',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: solde > 0
                                      ? AppTheme.warning
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Diviseur
                Container(
                  width: 1,
                  height: 100,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

                // Colonne de droite (Dernières Notes)
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dernières Notes',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!hasNotes)
                        const Text(
                          'Aucune note récente.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (hasNotes)
                        ...eleve.recentNotes!.take(3).map((note) {
                          // note == {matiere: "Math", note: 15, type: "Devoir 1"}
                          final double noteVal = (note['note'] as num)
                              .toDouble();
                          final Color noteColor = noteVal >= 10
                              ? AppTheme.success
                              : AppTheme.error;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note['matiere'] ?? 'Inconnu',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: noteColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${noteVal.toStringAsFixed(noteVal.truncateToDouble() == noteVal ? 0 : 1)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: noteColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Rapide (Régler scolarité) si solde > 0
          if (solde > 0)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinancesScreen(
                      enfants: _mesEnfants,
                      initialEleve: eleve,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RÉGLER LA SCOLARITÉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
