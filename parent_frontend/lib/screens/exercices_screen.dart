import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ExercicesScreen extends StatefulWidget {
  final List<Eleve> enfants;
  final Eleve initialEleve;

  const ExercicesScreen({
    super.key,
    required this.enfants,
    required this.initialEleve,
  });

  @override
  State<ExercicesScreen> createState() => _ExercicesScreenState();
}

class _ExercicesScreenState extends State<ExercicesScreen> {
  late Eleve _selectedEleve;
  bool _isLoading = true;
  List<dynamic> _exercices = [];

  @override
  void initState() {
    super.initState();
    _selectedEleve = widget.initialEleve;
    _fetchExercices();
  }

  Future<void> _fetchExercices() async {
    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getExercices(_selectedEleve.id);
    if (data != null && data['success'] == true) {
      if (mounted) {
        setState(() {
          _exercices = data['exercices'] ?? [];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les exercices'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Exercices & Devoirs'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (widget.enfants.length > 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: DropdownButtonFormField<Eleve>(
                value: _selectedEleve,
                decoration: InputDecoration(
                  labelText: 'Élève',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.enfants.map((Eleve eleve) {
                  return DropdownMenuItem<Eleve>(
                    value: eleve,
                    child: Text('${eleve.prenom} ${eleve.nom}'),
                  );
                }).toList(),
                onChanged: (Eleve? newEleve) {
                  if (newEleve != null) {
                    setState(() {
                      _selectedEleve = newEleve;
                    });
                    _fetchExercices();
                  }
                },
              ),
            ),
            
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exercices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('Aucun exercice trouvé', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchExercices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _exercices.length,
                          itemBuilder: (context, index) {
                            final exercice = _exercices[index];
                            final dateCours = DateTime.parse(exercice['date_cours']);
                            final bool isNonFait = exercice['is_non_fait'] == true;
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          exercice['matiere'] ?? 'Matière',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        if (isNonFait)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.red),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.close, color: Colors.red, size: 14),
                                                SizedBox(width: 4),
                                                Text('Non Fait', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                              ],
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text('À faire / Fait', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('dd MMMM yyyy', 'fr_FR').format(dateCours),
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text('À présenter à la prochaine séance :', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryDark)),
                                    const SizedBox(height: 4),
                                    Text(
                                      exercice['travail_a_faire'] ?? '',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Professeur: ${exercice['professeur']}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
