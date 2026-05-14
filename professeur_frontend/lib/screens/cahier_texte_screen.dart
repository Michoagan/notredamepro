import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/cahier_texte.dart';
import '../models/emploi_du_temps.dart';
import '../widgets/cahier_entry_card.dart';
import '../utils/theme.dart';
import '../widgets/premium_feedback.dart';
import '../widgets/premium_app_bar.dart';

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
  List<EmploiDuTemps> _monEmploiDuTemps = [];
  List<Classe> _filteredClasses = [];
  bool _isLoading = false;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  int _dureeCours = 1;
  late TimeOfDay _heureDebut;
  String _notionCours = '';
  String _travailAFaire = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _heureDebut = TimeOfDay.now();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadClasses(),
      _loadRecentEntries(),
      _loadEmploiDuTemps(),
    ]);
    setState(() => _isLoading = false);
    _filterClassesForSelectedDate();
  }

  Future<void> _loadEmploiDuTemps() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final emploi = await apiService.getEmploiDuTemps();
      _monEmploiDuTemps = emploi;
    } catch (e) {
      print('Erreur chargement emploi du temps: $e');
    }
  }

  String _getDayName(int num) {
    switch (num) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  void _filterClassesForSelectedDate() {
    final dayName = _getDayName(_selectedDate.weekday);
    final classesForDay = _monEmploiDuTemps
        .where((slot) => slot.jour == dayName)
        .map((slot) => slot.classeId)
        .toSet()
        .toList();

    setState(() {
      _filteredClasses =
          _classes.where((c) => classesForDay.contains(c.id)).toList();

      // Auto-select class and pre-fill if exactly one is found OR if the currently selected is invalid
      if (_filteredClasses.isNotEmpty) {
        if (_selectedClasse == null ||
            !_filteredClasses.any((c) => c.id == _selectedClasse!.id)) {
          _selectedClasse = _filteredClasses.first;
          _autoFillTimeForClass(_selectedClasse!.id, dayName);
        }
      } else {
        _selectedClasse = null;
      }
    });
  }

  void _autoFillTimeForClass(int classeId, String dayName) {
    final slot = _monEmploiDuTemps.firstWhere(
      (s) => s.classeId == classeId && s.jour == dayName,
      orElse: () => EmploiDuTemps(
          id: 0,
          classeId: 0,
          matiereId: 0,
          professeurId: 0,
          jour: '',
          heureDebut: '',
          heureFin: ''),
    );

    if (slot.id != 0 && slot.heureDebut != '' && slot.heureFin != '') {
      try {
        final startParts = slot.heureDebut.split(':');
        final endParts = slot.heureFin.split(':');

        final startH = int.parse(startParts[0]);
        final endH = int.parse(endParts[0]);

        setState(() {
          _heureDebut =
              TimeOfDay(hour: startH, minute: int.parse(startParts[1]));
          _dureeCours = (endH - startH).abs() > 0 ? (endH - startH).abs() : 1;
        });
      } catch (e) {
        print('Error parsing time: $e');
      }
    }
  }

  Future<void> _loadClasses() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final classes = await apiService.getClasses();
      _classes = classes;
    } catch (e) {
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

  /// Retourne true si l'enregistrement est réussi, false sinon.
  Future<bool> _submitEntry() async {
    if (_selectedClasse == null) {
      _showSnack('Aucune classe sélectionnée.');
      return false;
    }
    if (_notionCours.trim().isEmpty) {
      _showSnack('Le contenu du cours est requis.');
      return false;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final result = await apiService.storeCahierTexte(
        classeId: _selectedClasse!.id,
        matiereId: 0, // Le backend déduit matiere_id depuis le pivot
        dateCours: dateString,
        dureeCours: _dureeCours,
        heureDebut:
            '${_heureDebut.hour.toString().padLeft(2, '0')}:${_heureDebut.minute.toString().padLeft(2, '0')}',
        notionCours: _notionCours,
        travailAFaire: _travailAFaire,
      );

      if (result['success'] == true) {
        _loadRecentEntries();
        if (mounted) {
          PremiumFeedback.showSuccess(context, message: 'Cours enregistré !');
        }
        // Réinitialiser les champs
        _notionCours = '';
        _travailAFaire = '';
        return true;
      } else {
        if (mounted) {
          _showSnack(result['message'] ?? 'Erreur lors de l\'enregistrement.');
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erreur : $e');
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showAddEntryModal() {
    // Imposer aujourd'hui + auto-détecter les cours du jour
    setState(() {
      _selectedDate = DateTime.now();
      _filterClassesForSelectedDate();
    });

    // Textes locaux pour le modal (non liés au state global)
    final contentController = TextEditingController(text: _notionCours);
    final travailController = TextEditingController(text: _travailAFaire);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          // Slot actif depuis l'emploi du temps
          final dayName = _getDayName(_selectedDate.weekday);
          final slots = _monEmploiDuTemps
              .where((s) => s.jour == dayName)
              .toList();

          // Trouver la classe auto-sélectionnée
          Classe? classeActive = _selectedClasse;

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 44, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Titre
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.edit_note,
                              color: AppTheme.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Nouveau Cours',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary)),
                            Text(
                              DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                                  .format(_selectedDate),
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // ── Aucun cours prévu
                      if (slots.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Aucun cours prévu dans votre emploi du temps aujourd\'hui.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ]),
                        ),
                      ]
                      // ── Un ou plusieurs cours
                      else ...[
                        // Si plusieurs classes â†’ chips de sélection
                        if (_filteredClasses.length > 1) ...[
                          const Text(
                            'Cours du jour â€” Sélectionnez le cours actif :',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _filteredClasses.map((c) {
                              final isSelected =
                                  classeActive?.id == c.id;
                              // Trouver le slot correspondant
                              final slot = _monEmploiDuTemps.firstWhere(
                                (s) => s.classeId == c.id && s.jour == dayName,
                                orElse: () => EmploiDuTemps(
                                    id: 0, classeId: 0, matiereId: 0,
                                    professeurId: 0, jour: '', heureDebut: '',
                                    heureFin: ''),
                              );
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {});
                                  setState(() {
                                    _selectedClasse = c;
                                    _autoFillTimeForClass(c.id, dayName);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.primary.withOpacity(0.07),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.primary
                                                .withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (slot.id != 0)
                                        Text(
                                          '${slot.heureDebut} à ${slot.heureFin}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Bandeau info cours imposé
                        if (_selectedClasse != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0.08),
                                  AppTheme.primary.withOpacity(0.04)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _infoChip(Icons.class_,
                                    _selectedClasse!.displayName),
                                _infoChip(
                                    Icons.access_time,
                                    '${_heureDebut.hour.toString().padLeft(2, '0')}:${_heureDebut.minute.toString().padLeft(2, '0')}'),
                                _infoChip(Icons.timer,
                                    '$_dureeCours h'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Contenu du cours
                        const Text('Contenu du cours ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: contentController,
                          decoration: InputDecoration(
                            hintText:
                                'Ex: Introduction aux fractions, Correction exercice 3...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.primary, width: 2),
                            ),
                          ),
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Le contenu du cours est requis'
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // ── Exercice à faire
                        const Text('Exercice à faire',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: travailController,
                          decoration: InputDecoration(
                            hintText:
                                'Facultatif: ex. Exercices 1 et 2 page 45',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppTheme.primary, width: 2),
                            ),
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 28),

                        // ── Bouton Enregistrer
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: (_isSubmitting ||
                                    _selectedClasse == null ||
                                    slots.isEmpty)
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;
                                    _notionCours = contentController.text;
                                    _travailAFaire = travailController.text;
                                    await _submitEntry();
                                    if (mounted && context.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2))
                                : const Icon(Icons.save_as,
                                    color: Colors.white),
                            label: Text(
                              _isSubmitting
                                  ? 'Enregistrement...'
                                  : 'Enregistrer le cours',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              disabledBackgroundColor:
                                  Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Petit widget info (icône + texte) pour le bandeau récapitulatif
  Widget _infoChip(IconData icon, String label) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: AppTheme.primary, size: 20),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Cahier de Texte',
        subtitle: _recentEntries.isEmpty
            ? null
            : '${_recentEntries.length} cours enregistrés',
        actions: [
          PremiumActionBtn(
            icon: Icons.refresh_rounded,
            onTap: _loadRecentEntries,
          ),
        ],
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
                              entry: e, 
                              classeNom: e.classe?.nom,
                              onMarquerNonFait: e.travailAFaire.isNotEmpty ? () {
                                _showMarquerNonFaitDialog(e);
                              } : null,
                          ),
                        )),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
    );
  }

  void _showMarquerNonFaitDialog(CahierTexte entry) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final eleves = await apiService.getElevesByClasse(entry.classeId);
      Navigator.pop(context); // Close loading

      List<int> selectedEleves = List<int>.from(entry.elevesNonFaitsIds);

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Élèves n\'ayant pas fait l\'exercice'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: eleves.length,
                    itemBuilder: (context, index) {
                      final eleve = eleves[index];
                      return CheckboxListTile(
                        title: Text('${eleve.nom} ${eleve.prenom}'),
                        value: selectedEleves.contains(eleve.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedEleves.add(eleve.id);
                            } else {
                              selectedEleves.remove(eleve.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // close dialog
                      // Show loading
                      showDialog(
                        context: this.context,
                        barrierDismissible: false,
                        builder: (c) => const Center(child: CircularProgressIndicator()),
                      );

                      final result = await apiService.markExerciceNonFait(entry.id, selectedEleves);
                      Navigator.pop(this.context); // close loading

                      if (result['success'] == true) {
                        PremiumFeedback.showSuccess(this.context, message: 'Statut mis à jour');
                        _loadRecentEntries();
                      } else {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? 'Erreur'), backgroundColor: AppTheme.error),
                        );
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.error),
      );
    }
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