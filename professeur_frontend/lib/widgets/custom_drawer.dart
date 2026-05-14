import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/professeur.dart';
import '../screens/presences_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/cahier_texte_screen.dart';
import '../screens/analyse_notes_screen.dart';
import '../screens/salaires_screen.dart';
import '../screens/emploi_du_temps_screen.dart';
import '../screens/login_screen.dart';
import '../utils/theme.dart';

class CustomDrawer extends StatelessWidget {
  final Professeur professeur;

  const CustomDrawer({super.key, required this.professeur});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF060D1F),
              Color(0xFF0D1B3E),
              Color(0xFF122251),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // ── Header Premium ────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  children: [
                    // Logo avec halo doré
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE566), Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 76,
                            height: 76,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.school_rounded,
                              size: 44,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nom de l'école
                    const Text(
                      'Notre Dame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Toutes Grâces',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Slogan doré "In God We Trust"
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFE566), Color(0xFFFFD700), Color(0xFFFFA500)],
                      ).createShader(bounds),
                      child: const Text(
                        '✦ In God We Trust ✦',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info professeur
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A237E), Color(0xFF0D1B3E)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.gold.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                professeur.fullName.isNotEmpty
                                    ? professeur.fullName[0].toUpperCase()
                                    : 'P',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  professeur.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.gold.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    professeur.matiere,
                                    style: const TextStyle(
                                      color: AppTheme.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Séparateur doré ──────────────────────────────────────────
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFFFD700),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Menu Items ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildItem(context,
                    icon: Icons.dashboard_rounded,
                    title: 'Tableau de bord',
                    color: AppTheme.info,
                    onTap: () => Navigator.pop(context),
                    isSelected: true,
                  ),
                  _buildItem(context,
                    icon: Icons.fact_check_rounded,
                    title: 'Présences',
                    color: AppTheme.success,
                    onTap: () => _push(context, const PresencesScreen()),
                  ),
                  _buildItem(context,
                    icon: Icons.grade_rounded,
                    title: 'Notes',
                    color: AppTheme.gold,
                    onTap: () => _push(context, const NotesScreen()),
                  ),
                  _buildItem(context,
                    icon: Icons.menu_book_rounded,
                    title: 'Cahier de texte',
                    color: const Color(0xFFA78BFA),
                    onTap: () => _push(context, const CahierTexteScreen()),
                  ),
                  _buildItem(context,
                    icon: Icons.analytics_rounded,
                    title: 'Analyse pédagogique',
                    color: const Color(0xFF34D399),
                    onTap: () => _push(context, AnalyseNotesScreen(
                      profMatiereId:   professeur.matiereId,
                      profMatiereName: professeur.matiere,
                    )),
                  ),
                  _buildItem(context,
                    icon: Icons.calendar_month_rounded,
                    title: 'Emploi du temps',
                    color: const Color(0xFF818CF8),
                    onTap: () => _push(context, const EmploiDuTempsScreen()),
                  ),
                  _buildItem(context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Mes salaires',
                    color: const Color(0xFFFBBF24),
                    onTap: () => _push(context, SalairesScreen()),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white.withOpacity(0.08),
                  ),
                  const SizedBox(height: 8),

                  _buildItem(context,
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    color: const Color(0xFFF87171),
                    onTap: () async {
                      final apiService = Provider.of<ApiService>(
                          context, listen: false);
                      await apiService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // ── Footer "In God We Trust" ──────────────────────────────────
            Container(
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFE566), Color(0xFFFFD700), Color(0xFFFFA500)],
                    ).createShader(bounds),
                    child: const Text(
                      '✦  In God We Trust  ✦',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Notre Dame Toutes Grâces · v1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            )
          : null,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isSelected ? 0.4 : 0.15),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.6), blurRadius: 6),
                  ],
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}