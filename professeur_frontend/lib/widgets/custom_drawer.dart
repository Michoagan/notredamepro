import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/professeur.dart';
import '../screens/presences_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/cahier_texte_screen.dart';
import '../screens/analyse_notes_screen.dart';
import '../screens/login_screen.dart';
import '../utils/theme.dart';

class CustomDrawer extends StatelessWidget {
  final Professeur professeur;

  const CustomDrawer({super.key, required this.professeur});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: professeur.photoUrl != null
                        ? NetworkImage(professeur.photoUrl!)
                        : null,
                    child: professeur.photoUrl == null
                        ? Text(
                            '${professeur.firstName[0]}${professeur.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              accountName: Text(
                professeur.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                professeur.matiere,
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Tableau de bord',
                    onTap: () => Navigator.pop(context),
                    isSelected: true,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'Présences',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PresencesScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.grade_outlined,
                    title: 'Notes',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotesScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.book_outlined,
                    title: 'Cahier de texte',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CahierTexteScreen()),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Analyse',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AnalyseNotesScreen()),
                    ),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Déconnexion',
                    color: AppTheme.error,
                    onTap: () async {
                      final apiService = Provider.of<ApiService>(
                        context,
                        listen: false,
                      );
                      await apiService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: isSelected
          ? BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isSelected ? AppTheme.primary : Colors.grey[600]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                color ?? (isSelected ? AppTheme.primary : AppTheme.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
