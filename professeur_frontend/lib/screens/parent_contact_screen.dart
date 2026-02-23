import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/eleve.dart';
import '../models/classe.dart';
import '../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentContactScreen extends StatefulWidget {
  const ParentContactScreen({super.key});

  @override
  _ParentContactScreenState createState() => _ParentContactScreenState();
}

class _ParentContactScreenState extends State<ParentContactScreen> {
  int? _selectedClasseId;
  List<Classe> _classes = [];
  List<Eleve> _eleves = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final dashboardData = await apiService.getDashboardData();

      if (mounted) {
        setState(() {
          if (dashboardData['success'] == true) {
            _classes = (dashboardData['classes'] as List<Classe>?) ?? [];
            if (_classes.isNotEmpty) {
              _selectedClasseId = _classes.first.id;
              _loadEleves(_selectedClasseId!);
            } else {
              _isLoading = false;
            }
          } else {
            _errorMessage = 'Erreur lors du chargement des classes';
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEleves(int classeId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.getElevesByClasse(classeId);

      if (mounted) {
        setState(() {
          _eleves = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des élèves: $e';
          _isLoading = false;
        });
      }
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
          SnackBar(
              content: Text('Impossible de lancer l\'appel vers $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts Parents'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Class Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: DropdownButtonFormField<int>(
              value: _selectedClasseId,
              decoration: InputDecoration(
                labelText: 'Sélectionner une classe',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                prefixIcon:
                    const Icon(Icons.class_outlined, color: AppTheme.primary),
              ),
              items: _classes.map((classe) {
                return DropdownMenuItem<int>(
                  value: classe.id,
                  child: Text(classe.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedClasseId = value;
                  });
                  _loadEleves(value);
                }
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.orange),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _selectedClasseId != null
                                  ? _loadEleves(_selectedClasseId!)
                                  : _loadClasses(),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _eleves.isEmpty
                        ? const Center(
                            child: Text('Aucun élève dans cette classe'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _eleves.length,
                            itemBuilder: (context, index) {
                              final eleve = _eleves[index];
                              final hasParent = eleve.nomTuteur != null &&
                                  eleve.nomTuteur!.isNotEmpty;
                              final hasPhone = eleve.telephoneTuteur != null &&
                                  eleve.telephoneTuteur!.isNotEmpty;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppTheme.primary
                                                .withOpacity(0.1),
                                            child: Text(
                                              eleve.nom.substring(0, 1),
                                              style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${eleve.nom} ${eleve.prenom}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  'Matricule: ${eleve.id}', // Using ID as matricule placeholder if needed
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Divider(),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.family_restroom,
                                              size: 20,
                                              color: hasParent
                                                  ? Colors.grey[700]
                                                  : Colors.grey[300]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              hasParent
                                                  ? eleve.nomTuteur!
                                                  : 'Nom parent non disponible',
                                              style: TextStyle(
                                                color: hasParent
                                                    ? Colors.black87
                                                    : Colors.grey[400],
                                                fontStyle: hasParent
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 20,
                                              color: hasPhone
                                                  ? Colors.green[700]
                                                  : Colors.grey[300]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              hasPhone
                                                  ? eleve.telephoneTuteur!
                                                  : 'Numéro non disponible',
                                              style: TextStyle(
                                                color: hasPhone
                                                    ? Colors.black87
                                                    : Colors.grey[400],
                                                fontSize: 15,
                                                fontWeight: hasPhone
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (hasPhone)
                                            IconButton(
                                              icon: const CircleAvatar(
                                                backgroundColor: Colors.green,
                                                radius: 18,
                                                child: Icon(Icons.call,
                                                    color: Colors.white,
                                                    size: 20),
                                              ),
                                              onPressed: () => _makePhoneCall(
                                                  eleve.telephoneTuteur!),
                                              tooltip: 'Appeler',
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
        ],
      ),
    );
  }
}
