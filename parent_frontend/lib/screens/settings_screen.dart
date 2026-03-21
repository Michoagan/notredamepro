import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../models/eleve.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  String _parentName = "Parent";
  String _parentEmail = "";
  List<Eleve> _mesEnfants = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getDashboardData();

    if (data != null && data['success'] == true) {
      final parentData = data['parent'];
      String parentName = "Parent";
      String parentEmail = "";
      if (parentData != null) {
        parentName = "${parentData['prenom'] ?? ''} ${parentData['nom'] ?? ''}".trim();
        parentEmail = parentData['email'] ?? '';
      }

      final List<dynamic> elevesJson = data['eleves'] ?? [];
      final loadedEleves = elevesJson.map((e) => Eleve.fromJson(e)).toList();

      if (mounted) {
        setState(() {
          _parentName = parentName;
          _parentEmail = parentEmail;
          _mesEnfants = loadedEleves;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddRepetiteurModal(Eleve eleve) {
    final TextEditingController _phoneController = TextEditingController(text: eleve.repetiteurWhatsapp);
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ajouter un Répétiteur',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Numéro WhatsApp recevant les bilans pour ${eleve.prenom}.',
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Numéro WhatsApp (ex: +228...)',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final phone = _phoneController.text.trim();
                            setState(() => _isSubmitting = true);
                            final apiService = Provider.of<ApiService>(context, listen: false);
                            final res = await apiService.updateRepetiteur(eleve.id, phone);

                            setState(() => _isSubmitting = false);
                            if (mounted) {
                              Navigator.pop(context);
                              if (res['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Numéro du répétiteur mis à jour avec succès.'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                _loadData(); // Reload to see the new number
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Erreur'),
                                    backgroundColor: AppTheme.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'ENREGISTRER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              
              // Profil Section
              _buildSectionTitle('Mon Profil'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(Icons.person, color: AppTheme.primaryDark),
                  ),
                  title: Text(_parentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_parentEmail),
                ),
              ),
              const SizedBox(height: 32),

              // Répétiteur Section
              _buildSectionTitle('Répétiteurs (WhatsApp)'),
              const SizedBox(height: 12),
              if (_mesEnfants.isEmpty)
                const Text('Aucun enfant trouvé.', style: TextStyle(color: AppTheme.textSecondary))
              else
                ..._mesEnfants.map((eleve) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade50,
                          child: const Icon(Icons.school, color: Colors.teal),
                        ),
                        title: Text(eleve.prenom, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          (eleve.repetiteurWhatsapp != null && eleve.repetiteurWhatsapp!.isNotEmpty)
                              ? eleve.repetiteurWhatsapp!
                              : 'Aucun répétiteur défini',
                          style: TextStyle(
                            color: (eleve.repetiteurWhatsapp != null && eleve.repetiteurWhatsapp!.isNotEmpty)
                                ? AppTheme.textPrimary
                                : AppTheme.warning,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
                          onPressed: () => _showAddRepetiteurModal(eleve),
                        ),
                      ),
                    )),
              const SizedBox(height: 32),

              // Sécurité & Actions
              _buildSectionTitle('Sécurité'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_rounded, color: AppTheme.primary),
                      title: const Text('Changer de mot de passe', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                      },
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                      title: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.error)),
                      onTap: () async {
                        final apiService = Provider.of<ApiService>(context, listen: false);
                        await apiService.logout();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
