import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';

class ExercicesNonFaitsScreen extends StatefulWidget {
  final List<Classe> classes;
  const ExercicesNonFaitsScreen({Key? key, required this.classes}) : super(key: key);

  @override
  _ExercicesNonFaitsScreenState createState() => _ExercicesNonFaitsScreenState();
}

class _ExercicesNonFaitsScreenState extends State<ExercicesNonFaitsScreen> {
  bool _isLoading = false;
  int? _selectedClasseId;
  List<dynamic> _eleves = [];
  final Map<int, bool> _loadingEleve = {};

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
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final response = await api.getConduites(classeId: _selectedClasseId!, trimestre: 1);
      if (response['success'] == true && mounted) {
        setState(() { _eleves = response['eleves'] as List<dynamic>; _isLoading = false; });
      } else {
        _showSnack(response['message'] ?? 'Erreur', isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack('Erreur de connexion', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signaler(int eleveId, String prenom) async {
    final bool? confirmer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
          SizedBox(width: 10),
          Text('Confirmer', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        content: Text('Signaler que $prenom n\'a pas fait son devoir ?\n\nUne notification sera envoyée aux parents.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
    if (confirmer != true) return;
    setState(() => _loadingEleve[eleveId] = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final response = await api.signalerExerciceNonFait(eleveId);
      if (response['success'] == true && mounted) {
        _showSnack(response['message'] ?? 'Signalement envoyé', isError: false);
      } else {
        _showSnack(response['message'] ?? 'Erreur', isError: true);
      }
    } catch (e) {
      _showSnack('Erreur de connexion', isError: true);
    } finally {
      if (mounted) setState(() => _loadingEleve[eleveId] = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final className = _selectedClasseId != null
        ? widget.classes.firstWhere((c) => c.id == _selectedClasseId, orElse: () => widget.classes.first).displayName
        : '';
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Devoirs Non Faits',
        subtitle: className.isNotEmpty ? className : 'Signalement parents',
        showBack: true,
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedClasseId,
                  decoration: InputDecoration(
                    labelText: 'Classe',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                    prefixIcon: const Icon(Icons.class_rounded, color: AppTheme.primary, size: 20),
                  ),
                  items: widget.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.displayName, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) { setState(() => _selectedClasseId = v); _loadEleves(); },
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withAlpha(10), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEF4444).withAlpha(40))),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Appuyez sur ⚠ pour signaler un devoir non rendu aux parents', style: TextStyle(color: Colors.grey.shade700, fontSize: 12))),
                  ]),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _eleves.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Aucun élève dans cette classe', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _eleves.length,
                        itemBuilder: (context, index) {
                          final eleve = _eleves[index];
                          final id = eleve['id'] as int;
                          final isProcessing = _loadingEleve[id] ?? false;
                          final initials = '${eleve['nom'][0]}${eleve['prenom'][0]}'.toUpperCase();
                          final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
                          final color = colors[index % colors.length];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withAlpha(180)]), borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
                              ),
                              title: Text('${eleve['nom']} ${eleve['prenom']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                              subtitle: Text('Matricule: ${eleve['matricule'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                              trailing: isProcessing
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                                  : GestureDetector(
                                      onTap: () => _signaler(id, eleve['prenom'] as String),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFEF4444).withAlpha(15), borderRadius: BorderRadius.circular(10)),
                                        child: const Icon(Icons.assignment_late_rounded, color: Color(0xFFEF4444), size: 22),
                                      ),
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
