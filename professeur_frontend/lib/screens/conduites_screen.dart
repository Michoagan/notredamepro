import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../utils/theme.dart';

class ConduitesScreen extends StatefulWidget {
  final List<Classe> classes;

  const ConduitesScreen({Key? key, required this.classes}) : super(key: key);

  @override
  _ConduitesScreenState createState() => _ConduitesScreenState();
}

class _ConduitesScreenState extends State<ConduitesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  int? _selectedClasseId;
  int _selectedTrimestre = 1;

  List<dynamic> _eleves = [];
  Map<int, TextEditingController> _noteControllers = {};
  Map<int, TextEditingController> _appreciationControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.classes.isNotEmpty) {
      _selectedClasseId = widget.classes.first.id;
      _loadConduites();
    }
  }

  @override
  void dispose() {
    _noteControllers.values.forEach((c) => c.dispose());
    _appreciationControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _loadConduites() async {
    if (_selectedClasseId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getConduites(
        classeId: _selectedClasseId!,
        trimestre: _selectedTrimestre,
      );

      if (response['success'] == true && mounted) {
        final elevesData = response['eleves'] as List<dynamic>;

        // Initialize controllers
        _noteControllers.clear();
        _appreciationControllers.clear();

        for (var eleve in elevesData) {
          int id = eleve['id'];
          _noteControllers[id] =
              TextEditingController(text: eleve['note']?.toString() ?? '');
          _appreciationControllers[id] = TextEditingController(
              text: eleve['appreciation']?.toString() ?? '');
        }

        setState(() {
          _eleves = elevesData;
          _isLoading = false;
        });
      } else {
        _showError(response['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      _showError('Erreur de connexion');
    }
  }

  Future<void> _saveConduites() async {
    if (_selectedClasseId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> conduitesData = [];

      for (var eleve in _eleves) {
        int id = eleve['id'];
        String noteText = _noteControllers[id]?.text ?? '';
        String appreciation = _appreciationControllers[id]?.text ?? '';

        if (noteText.isNotEmpty || appreciation.isNotEmpty) {
          conduitesData.add({
            'eleve_id': id,
            'note': noteText.isNotEmpty ? double.tryParse(noteText) : null,
            'appreciation': appreciation,
          });
        }
      }

      final response = await _apiService.storeConduites(
        classeId: _selectedClasseId!,
        trimestre: _selectedTrimestre,
        conduites: conduitesData,
      );

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Notes enregistrées'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        _showError(response['message'] ?? 'Erreur lors de l\'enregistrement');
      }
    } catch (e) {
      _showError('Erreur de connexion');
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
        title: const Text('Conduite'),
        backgroundColor: AppTheme.primary,
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
                          'Aucun élève ou accès non autorisé\n(Seul le professeur principal peut gérer la conduite)',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _buildElevesList(),
          ),
        ],
      ),
      floatingActionButton: _eleves.isNotEmpty && _hasUnsavedConduites()
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _saveConduites,
              label: const Text('Enregistrer'),
              icon: const Icon(Icons.save),
              backgroundColor: AppTheme.primary,
            )
          : null,
    );
  }

  bool _hasUnsavedConduites() {
    for (var eleve in _eleves) {
      if ((eleve['note'] == null || eleve['note'].toString().isEmpty) &&
          (eleve['appreciation'] == null ||
              eleve['appreciation'].toString().isEmpty)) {
        return true;
      }
    }
    return false;
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
              _loadConduites();
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedTrimestre,
            decoration: const InputDecoration(
              labelText: 'Trimestre',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1er Trimestre')),
              DropdownMenuItem(value: 2, child: Text('2ème Trimestre')),
              DropdownMenuItem(value: 3, child: Text('3ème Trimestre')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTrimestre = value!;
              });
              _loadConduites();
            },
          ),
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

        final bool hasExistingConduite =
            (eleve['note'] != null && eleve['note'].toString().isNotEmpty) ||
                (eleve['appreciation'] != null &&
                    eleve['appreciation'].toString().isNotEmpty);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        eleve['nom'][0] + eleve['prenom'][0],
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${eleve['nom']} ${eleve['prenom']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Matricule: ${eleve['matricule']}',
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _noteControllers[eleveId],
                        enabled: !hasExistingConduite,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Note (/20)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _appreciationControllers[eleveId],
                        enabled: !hasExistingConduite,
                        decoration: const InputDecoration(
                          labelText: 'Appréciation (Conduite)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
