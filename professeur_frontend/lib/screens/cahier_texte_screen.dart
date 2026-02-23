import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/cahier_texte.dart';
import '../models/professeur.dart';
import '../widgets/cahier_entry_card.dart';
import '../utils/theme.dart';
import '../widgets/premium_feedback.dart';

class CahierTexteScreen extends StatefulWidget {
  const CahierTexteScreen({super.key});

  @override
  _CahierTexteScreenState createState() => _CahierTexteScreenState();
}

class _CahierTexteScreenState extends State<CahierTexteScreen> {
  late List<Classe> _classes = [];
  Classe? _selectedClasse;
  DateTime _selectedDate = DateTime.now();
  List<CahierTexte> _recentEntries = [];
  bool _isLoading = false;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  int _dureeCours = 1;
  late TimeOfDay _heureDebut;
  String _notionCours = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _heureDebut = TimeOfDay.now();
    _loadClasses();
    _loadRecentEntries();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final classes = await apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
        if (classes.isNotEmpty) {
          _selectedClasse = classes.first; // Default selection
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur chargement classes: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _loadRecentEntries() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final entries = await apiService.getCahierTexte();
      setState(() => _recentEntries = entries);
    } catch (e) {
      if (mounted) {
        // Silently fail or log
        print('Erreur chargement entrées: $e');
      }
    }
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClasse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une classe')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Get prof profile to get matiere_id
      final professeurProfile = await apiService.getProfile();
      final professeurData = professeurProfile['professeur'];
      final professeur = professeurData is Professeur
          ? professeurData
          : Professeur.fromJson(professeurData);

      if (professeur.matiereId == 0) {
        throw Exception("Aucune matière associée à votre profil.");
      }

      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final result = await apiService.storeCahierTexte(
        classeId: _selectedClasse!.id,
        matiereId: professeur.matiereId,
        dateCours: dateString,
        dureeCours: _dureeCours,
        heureDebut: _heureDebut.format(context),
        notionCours: _notionCours,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          _loadRecentEntries(); // Refresh list
          PremiumFeedback.showSuccess(context, message: 'Saisie enregistrée !');
          // Reset specific fields for next time
          _notionCours = '';
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showAddEntryModal() {
    // Reset inputs to current moment
    setState(() {
      _selectedDate = DateTime.now();
      _heureDebut = TimeOfDay.now();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_note,
                        color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouveau Cours',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Remplissez le cahier de texte',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Classe Selection
                      const Text('Classe',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Classe>(
                        value: _selectedClasse,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        items: _classes
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c.displayName)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClasse = v),
                      ),

                      const SizedBox(height: 20),

                      // Date & Heure Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null)
                                      setState(() => _selectedDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 18, color: AppTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Heure Début',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _heureDebut,
                                    );
                                    if (picked != null)
                                      setState(() => _heureDebut = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 18, color: AppTheme.primary),
                                        const SizedBox(width: 8),
                                        Text(_heureDebut.format(context)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Durée Slider
                      const Text('Durée du cours',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _dureeCours,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          prefixIcon:
                              const Icon(Icons.timer, color: AppTheme.primary),
                        ),
                        items: [1, 2, 3, 4, 5, 6, 7, 8]
                            .map((hours) => DropdownMenuItem(
                                  value: hours,
                                  child: Text(
                                      '$hours heure${hours > 1 ? 's' : ''}'),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _dureeCours = val!),
                      ),

                      const SizedBox(height: 20),

                      // Notion Content
                      const Text('Contenu du cours',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _notionCours,
                        decoration: InputDecoration(
                          hintText:
                              'Ex: Introduction aux polynômes, Exercices page 42...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 4,
                        validator: (v) =>
                            v!.isEmpty ? 'Ce champ est requis' : null,
                        onSaved: (v) => _notionCours = v!,
                      ),

                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_as, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Enregistrer le Cours',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20), // Padding bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Cahier de Texte',
          style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryModal,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau Cours',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecentEntries,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStatHeader(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Historique Récent',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                      TextButton.icon(
                        onPressed: _loadRecentEntries,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Actualiser'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recentEntries.isEmpty)
                    _buildEmptyState()
                  else
                    ..._recentEntries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CahierEntryCard(
                              entry: e, classeNom: e.classe?.nom),
                        )),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
    );
  }

  Widget _buildStatHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme
            .primary, // Using primary color directly for a solid modern look
        borderRadius: BorderRadius.circular(24), // Softer, larger radius
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total des cours enregistrés',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_recentEntries.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.library_books_rounded,
                  size: 64, color: AppTheme.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune entrée pour le moment',
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Remplissez votre premier cahier de texte en appuyant sur le bouton ci-dessous.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddEntryModal,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un cours'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
