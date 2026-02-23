import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Communiqués & Messages'),
          toolbarHeight: 80,
          bottom: TabBar(
            indicatorColor: AppTheme.accent,
            indicatorWeight: 4,
            labelColor: AppTheme.accent,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'Actualités'),
              Tab(text: 'Contacter l\'école'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [_ActualitesTab(), _ContactTab()],
        ),
      ),
    );
  }
}

class _ActualitesTab extends StatelessWidget {
  const _ActualitesTab();

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    return FutureBuilder<Map<String, dynamic>?>(
      future: apiService.getDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
                  'Impossible de charger les actualités.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final evenements =
            (snapshot.data!['evenements'] as List<dynamic>?) ?? [];

        if (evenements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feed_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun événement récent.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: evenements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final ev = evenements[index];
            final titre = ev['titre'] ?? 'Événement';
            final description = ev['description'] ?? '';
            final dateString = ev['date'] ?? ev['created_at'] ?? '';
            final date = dateString.isNotEmpty
                ? (dateString as String).substring(0, 10)
                : '';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.campaign_rounded,
                                size: 14,
                                color: AppTheme.primaryDark,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ÉVÉNEMENT',
                                style: TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactTab extends StatefulWidget {
  const _ContactTab();

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  final _formKey = GlobalKey<FormState>();
  String? _sujet = 'Scolarite';
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.sendMessage(
      _sujet ?? 'Scolarite',
      _messageController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Votre message a été envoyé avec succès.')),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
      _messageController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Erreur lors de l\'envoi du message.')),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Envoyer un message',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Utilisez ce formulaire pour soumettre une suggestion, signaler un problème, ou contacter la direction.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                DropdownButtonFormField<String>(
                  initialValue: _sujet,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.primary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Sujet du message',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Scolarite',
                      child: Text('Scolarité de mon enfant'),
                    ),
                    DropdownMenuItem(
                      value: 'Justification',
                      child: Text('Justification d\'absence'),
                    ),
                    DropdownMenuItem(
                      value: 'Finances',
                      child: Text('Questions Financières'),
                    ),
                    DropdownMenuItem(
                      value: 'Suggestion',
                      child: Text('Suggestion ou Remarque'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _sujet = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Votre Message',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: 96,
                      ), // Align icon to top visually
                      child: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _isLoading ? 'ENVOI...' : 'ENVOYER',
                      style: const TextStyle(fontSize: 16),
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
}
