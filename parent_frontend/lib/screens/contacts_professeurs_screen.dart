import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ContactsProfesseursScreen extends StatefulWidget {
  final Eleve eleve;

  const ContactsProfesseursScreen({super.key, required this.eleve});

  @override
  // ignore: library_private_types_in_public_api
  _ContactsProfesseursScreenState createState() => _ContactsProfesseursScreenState();
}

class _ContactsProfesseursScreenState extends State<ContactsProfesseursScreen> {
  bool _isLoading = true;
  List<dynamic> _professeurs = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfesseurs();
  }

  Future<void> _loadProfesseurs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final professeurs = await apiService.getProfesseurs(widget.eleve.id);
      
      if (!mounted) return;
      
      setState(() {
        _professeurs = professeurs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des contacts.';
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de lancer l\'appel.')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'application email.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Professeurs', style: TextStyle(fontSize: 16)),
            Text(
              widget.eleve.prenom,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfesseurs,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _professeurs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun professeur trouvé pour cette classe.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProfesseurs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _professeurs.length,
                        itemBuilder: (context, index) {
                          final prof = _professeurs[index];
                          final matieresDetails = (prof['matieres'] as List<dynamic>).join(', ');
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                        child: Text(
                                          '${(prof['nom']?.toString().isNotEmpty == true ? prof['nom'][0] : '')}${(prof['prenom']?.toString().isNotEmpty == true ? prof['prenom'][0] : '')}'.toUpperCase(),
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${prof['nom'] ?? ''} ${prof['prenom'] ?? ''}'.trim(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              matieresDetails,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (prof['telephone'] != null && prof['telephone'].toString().isNotEmpty)
                                        TextButton.icon(
                                          onPressed: () => _makePhoneCall(prof['telephone']),
                                          icon: const Icon(Icons.phone, color: Colors.green),
                                          label: const Text('Appeler', style: TextStyle(color: Colors.green)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                        ),
                                      if (prof['email'] != null && prof['email'].toString().isNotEmpty)
                                        TextButton.icon(
                                          onPressed: () => _sendEmail(prof['email']),
                                          icon: const Icon(Icons.email, color: AppTheme.primary),
                                          label: const Text('Email', style: TextStyle(color: AppTheme.primary)),
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
