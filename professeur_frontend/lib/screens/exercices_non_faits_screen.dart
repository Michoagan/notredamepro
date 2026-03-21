import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../utils/theme.dart';

class ExercicesNonFaitsScreen extends StatefulWidget {
  final List<Classe> classes;

  const ExercicesNonFaitsScreen({Key? key, required this.classes}) : super(key: key);

  @override
  _ExercicesNonFaitsScreenState createState() => _ExercicesNonFaitsScreenState();
}

class _ExercicesNonFaitsScreenState extends State<ExercicesNonFaitsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  int? _selectedClasseId;
  List<dynamic> _eleves = [];
  Map<int, bool> _loadingEleve = {};

  @override
  void initState() {
    super.initState();
    if (widget.classes.isNotEmpty) {
      _selectedClasseId = widget.classes.first.id;
      _loadEleves();
    }
  }

  Future<void> _loadEleves() async {
    if (_selectedClasseId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getConduites(
        classeId: _selectedClasseId!,
        trimestre: 1, // We only need the list of students, any term will do
      );

      if (response['success'] == true && mounted) {
        setState(() {
          _eleves = response['eleves'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        _showError(response['message'] ?? 'Erreur lors du chargement des élèves');
      }
    } catch (e) {
      _showError('Erreur de connexion');
    }
  }

  Future<void> _signalerExerciceNonFait(int eleveId, String prenom) async {
    // Confirmation dialog
    final bool? confirmer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Voulez-vous vraiment signaler que $prenom n\'a pas fait son exercice ?\n\nUne notification sera envoyée à ses parents.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Signaler'),
            ),
          ],
        );
      },
    );

    if (confirmer != true) return;

    setState(() {
      _loadingEleve[eleveId] = true;
    });

    try {
      final response = await _apiService.signalerExerciceNonFait(eleveId);

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Signalement envoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showError(response['message'] ?? 'Erreur lors du signalement');
      }
    } catch (e) {
      _showError('Erreur de connexion');
    } finally {
      if (mounted) {
        setState(() {
          _loadingEleve[eleveId] = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devoirs Non Faits'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _eleves.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun élève trouvé pour cette classe',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _buildElevesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedClasseId,
            decoration: const InputDecoration(
              labelText: 'Classe',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: widget.classes.map((classe) {
              return DropdownMenuItem<int>(
                value: classe.id,
                child: Text(classe.nom),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClasseId = value;
              });
              _loadEleves();
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Sélectionnez un élève pour signaler un devoir non fait aux parents.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildElevesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eleves.length,
      itemBuilder: (context, index) {
        final eleve = _eleves[index];
        final eleveId = eleve['id'];
        final isProcessing = _loadingEleve[eleveId] ?? false;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                eleve['nom'][0] + eleve['prenom'][0],
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              '${eleve['nom']} ${eleve['prenom']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Matricule: ${eleve['matricule']}'),
            trailing: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.assignment_late, color: Colors.redAccent),
                    onPressed: () => _signalerExerciceNonFait(eleveId, eleve['prenom']),
                    tooltip: 'Signaler devoir non fait',
                  ),
          ),
        );
      },
    );
  }
}
