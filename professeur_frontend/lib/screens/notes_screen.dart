import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../models/eleve.dart';
import '../models/moyenne.dart';
import '../models/professeur.dart';
import '../widgets/note_input_dialog.dart';
import '../widgets/moyenne_table.dart';
import '../services/pdf_service.dart';
import '../services/csv_service.dart';
import '../utils/theme.dart';
import '../widgets/premium_feedback.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<Classe> _classes = [];
  Classe? _selectedClasse;
  int _selectedTrimestre = 1;
  String _selectedTypeNote = 'interro';
  int _selectedNumero = 1;
  List<Eleve> _eleves = [];
  final Map<String, dynamic> _notes = {};
  Map<String, dynamic> _existingNotes = {};
  List<Moyenne> _moyennes = [];
  bool _isLoading = false;
  bool _showMoyennes = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final classes = await apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des classes: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _loadEleves() async {
    if (_selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final professeurProfile = await apiService.getProfile();
      final professeurData = professeurProfile['professeur'];
      final professeur = professeurData is Professeur
          ? professeurData
          : Professeur.fromJson(professeurData);

      if (professeur.matiereId == 0) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Aucune matière principale associée à votre profil. Contactez l\'administrateur.'),
              backgroundColor: AppTheme.warning),
        );
        return;
      }

      // Charger les élèves ET les notes existantes
      final result = await apiService.getNotes(
        classeId: _selectedClasse!.id,
        trimestre: _selectedTrimestre,
        matiereId: professeur.matiereId,
      );

      if (result['success'] == true) {
        setState(() {
          _eleves = result['eleves'] as List<Eleve>;

          // Traiter les notes existantes
          _existingNotes = {};
          final notesData = result['notes'];

          if (notesData != null) {
            // Déterminer la clé de note à chercher en fonction du type et numéro
            String key;
            if (_selectedTypeNote == 'interro') {
              key = _selectedNumero == 1
                  ? 'premier_interro'
                  : _selectedNumero == 2
                      ? 'deuxieme_interro'
                      : _selectedNumero == 3
                          ? 'troisieme_interro'
                          : 'quatrieme_interro';
            } else {
              key = _selectedNumero == 1 ? 'premier_devoir' : 'deuxieme_devoir';
            }

            // Le backend renvoie une Map<String, dynamic> où la clé est l'ID élève
            if (notesData is Map) {
              notesData.forEach((eleveId, noteObj) {
                if (noteObj != null && noteObj[key] != null) {
                  _existingNotes[eleveId.toString()] = noteObj[key];
                }
              });
            }
          }

          _isLoading = false;
          _showMoyennes = false;
        });
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des élèves: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _loadMoyennes() async {
    if (_selectedClasse == null) return;

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final professeurProfile = await apiService.getProfile();
      final professeurData = professeurProfile['professeur'];
      final professeur = professeurData is Professeur
          ? professeurData
          : Professeur.fromJson(professeurData);

      if (professeur.matiereId == 0) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Aucune matière principale associée à votre profil.'),
              backgroundColor: AppTheme.warning),
        );
        return;
      }

      final moyennes = await apiService.calculerMoyennes(
        classeId: _selectedClasse!.id,
        trimestre: _selectedTrimestre,
        matiereId: professeur.matiereId,
      );

      setState(() {
        _moyennes = moyennes;
        _isLoading = false;
        _showMoyennes = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du calcul des moyennes: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _saveNotes() async {
    if (_notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Aucune note à enregistrer'),
          backgroundColor: AppTheme.secondary));
      return;
    }

    final notesExtremes = _notes.values.where((note) {
      final numValue =
          note is num ? note.toDouble() : double.tryParse(note.toString());
      return numValue == null || numValue < 0 || numValue > 20;
    }).toList();

    if (notesExtremes.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notes invalides détectées'),
          content: Text(
              '${notesExtremes.length} note(s) sont en dehors de la plage normale (0-20). Voulez-vous vraiment enregistrer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final professeurProfile = await apiService.getProfile();
      final professeurData = professeurProfile['professeur'];
      final professeur = professeurData is Professeur
          ? professeurData
          : Professeur.fromJson(professeurData);

      final result = await apiService.storeNotes(
        classeId: _selectedClasse!.id,
        trimestre: _selectedTrimestre,
        matiereId: professeur.matiereId,
        typeNote: _selectedTypeNote,
        numero: _selectedNumero,
        notes: _notes,
      );

      setState(() {
        _notes.clear();
        _isLoading = false;
      });

      if (mounted) {
        if (result['success'] == true) {
          PremiumFeedback.showSuccess(context,
              message: result['message'] ?? 'Notes enregistrées !');
          _loadEleves();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(result['message'] ?? 'Erreur lors de l\'enregistrement'),
              backgroundColor: AppTheme.error));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'enregistrement: $e'),
              backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showNoteInputDialog(Eleve eleve) {
    final existingNoteValue = _getExistingNoteValue(eleve.id);
    final isAlreadyGraded = existingNoteValue != null;

    if (isAlreadyGraded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cet élève a déjà été noté'),
          backgroundColor: AppTheme.secondary));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => NoteInputDialog(
        eleve: eleve,
        currentValue: existingNoteValue,
        onSave: (note) {
          setState(() => _notes[eleve.id.toString()] = note);
          Navigator.pop(context);
        },
      ),
    );
  }

  double? _getExistingNoteValue(int eleveId) {
    final noteData = _existingNotes[eleveId.toString()];
    if (noteData is num) {
      return noteData.toDouble();
    }
    return null;
  }

  String _getNoteTypeDisplay() {
    if (_selectedTypeNote == 'interro') {
      return 'Interrogation $_selectedNumero';
    } else {
      return 'Devoir $_selectedNumero';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie des Notes'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestion des Notes',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Saisissez et consultez les notes',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calculate_rounded,
                              color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Configuration
                  Card(
                    // Theme handles elevation and shape
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 20),

                          // Sélection de la classe
                          DropdownButtonFormField<Classe>(
                            initialValue: _selectedClasse,
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Sélectionnez une classe'),
                              ),
                              ..._classes.map((classe) {
                                return DropdownMenuItem(
                                  value: classe,
                                  child: Text(classe.displayName),
                                );
                              }).toList(),
                            ],
                            onChanged: (classe) {
                              setState(() => _selectedClasse = classe);
                              if (classe != null) _loadEleves();
                            },
                            decoration: InputDecoration(
                              labelText: 'Classe',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.school_rounded,
                                  color: AppTheme.primary),
                              filled: true,
                              fillColor: AppTheme.background,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              // Sélection du trimestre
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _selectedTrimestre,
                                  items: [1, 2, 3].map((trimestre) {
                                    return DropdownMenuItem(
                                      value: trimestre,
                                      child: Text('Trimestre $trimestre'),
                                    );
                                  }).toList(),
                                  onChanged: (trimestre) {
                                    setState(
                                        () => _selectedTrimestre = trimestre!);
                                    _loadEleves();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Trimestre',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    prefixIcon: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppTheme.secondary),
                                    filled: true,
                                    fillColor: AppTheme.background,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Sélection du type de note
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedTypeNote,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'interro',
                                      child: Text('Interro'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'devoir',
                                      child: Text('Devoir'),
                                    ),
                                  ],
                                  onChanged: (type) {
                                    setState(() {
                                      _selectedTypeNote = type!;
                                      _selectedNumero = 1;
                                    });
                                    _loadEleves();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    prefixIcon: const Icon(
                                        Icons.assignment_rounded,
                                        color: AppTheme.accent),
                                    filled: true,
                                    fillColor: AppTheme.background,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Sélection du numéro
                          DropdownButtonFormField<int>(
                            initialValue: _selectedNumero,
                            items: (_selectedTypeNote == 'interro'
                                    ? [1, 2, 3, 4]
                                    : [1, 2])
                                .map((numero) {
                              return DropdownMenuItem(
                                value: numero,
                                child: Text(
                                  _selectedTypeNote == 'interro'
                                      ? 'Interrogation $numero'
                                      : 'Devoir $numero',
                                ),
                              );
                            }).toList(),
                            onChanged: (numero) {
                              setState(() => _selectedNumero = numero!);
                              _loadEleves();
                            },
                            decoration: InputDecoration(
                              labelText: 'Numéro de l\'évaluation',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.numbers_rounded,
                                  color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Liste des élèves et saisie des notes
                  if (_selectedClasse != null && _eleves.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saisie des notes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getNoteTypeDisplay(),
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_eleves.length} élèves',
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _eleves.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final eleve = _eleves[index];
                                final existingNoteValue =
                                    _getExistingNoteValue(eleve.id);
                                final isAlreadyGraded =
                                    existingNoteValue != null;
                                final newNote = _notes[eleve.id.toString()];
                                final hasNewNote = newNote != null;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 0),
                                  leading: CircleAvatar(
                                    backgroundColor: hasNewNote
                                        ? AppTheme.secondary
                                        : (isAlreadyGraded
                                            ? AppTheme.primary
                                            : Colors.grey.shade200),
                                    foregroundColor:
                                        hasNewNote || isAlreadyGraded
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                    child: Text(
                                        '${eleve.prenom[0]}${eleve.nom[0]}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text('${eleve.prenom} ${eleve.nom}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppTheme.textPrimary)),
                                  subtitle: Text('ID: ${eleve.id}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary)),
                                  trailing: SizedBox(
                                    width: 140,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (isAlreadyGraded)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.green.shade200),
                                            ),
                                            child: Text(
                                              existingNoteValue
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        else if (hasNewNote)
                                          GestureDetector(
                                            onTap: () =>
                                                _showNoteInputDialog(eleve),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color:
                                                        Colors.blue.shade200),
                                              ),
                                              child: Text(
                                                '${newNote.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        else
                                          TextButton.icon(
                                            onPressed: () =>
                                                _showNoteInputDialog(eleve),
                                            icon: const Icon(Icons.edit_rounded,
                                                size: 16),
                                            label: const Text('Noter'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppTheme.primary,
                                            ),
                                          ),
                                        if (!isAlreadyGraded && hasNewNote)
                                          IconButton(
                                            icon: const Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                                color: Colors.grey),
                                            onPressed: () {
                                              setState(() {
                                                _notes.remove(
                                                    eleve.id.toString());
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _notes.isNotEmpty ? _saveNotes : null,
                                    child: const Text('Enregistrer les notes'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _loadMoyennes,
                                icon: const Icon(Icons.analytics_outlined),
                                label: const Text(
                                    'Calculer et afficher les moyennes'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Affichage des moyennes
                  if (_showMoyennes && _moyennes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Moyennes et Classement',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_selectedClasse!.displayName} - Trimestre $_selectedTrimestre',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () async {
                                            await CsvService
                                                .generateAndDownloadCsv(
                                              moyennes: _moyennes,
                                              classeName:
                                                  _selectedClasse!.displayName,
                                              matiereName: 'Matière Principale',
                                              trimestre: _selectedTrimestre,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.table_view_rounded),
                                          tooltip: 'Télécharger Excel (CSV)',
                                          color: Colors.green,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () async {
                                            final apiService =
                                                Provider.of<ApiService>(context,
                                                    listen: false);
                                            final profile =
                                                await apiService.getProfile();
                                            final profName =
                                                '${profile['professeur']['prenom']} ${profile['professeur']['nom']}';

                                            await PdfService
                                                .generateAndDownloadBulletin(
                                              moyennes: _moyennes,
                                              classeName:
                                                  _selectedClasse!.displayName,
                                              matiereName: 'Matière Principale',
                                              trimestre: _selectedTrimestre,
                                              profName: profName,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.picture_as_pdf_rounded),
                                          tooltip: 'Télécharger PDF',
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              MoyenneTable(moyennes: _moyennes),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
