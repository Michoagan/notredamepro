import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/classe.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';
import 'package:provider/provider.dart';

class ConduitesScreen extends StatefulWidget {
  final List<Classe> classes;
  const ConduitesScreen({Key? key, required this.classes}) : super(key: key);

  @override
  _ConduitesScreenState createState() => _ConduitesScreenState();
}

class _ConduitesScreenState extends State<ConduitesScreen> {
  bool _isLoading = false;
  int? _selectedClasseId;
  int _selectedTrimestre = 1;
  List<dynamic> _eleves = [];
  final Map<int, TextEditingController> _noteControllers = {};
  final Map<int, TextEditingController> _appreciationControllers = {};

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
    for (final c in _noteControllers.values) { c.dispose(); }
    for (final c in _appreciationControllers.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadConduites() async {
    if (_selectedClasseId == null) return;
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final response = await api.getConduites(classeId: _selectedClasseId!, trimestre: _selectedTrimestre);
      if (response['success'] == true && mounted) {
        final elevesData = response['eleves'] as List<dynamic>;
        _noteControllers.clear();
        _appreciationControllers.clear();
        for (var e in elevesData) {
          final id = e['id'] as int;
          _noteControllers[id] = TextEditingController(text: e['note']?.toString() ?? '');
          _appreciationControllers[id] = TextEditingController(text: e['appreciation']?.toString() ?? '');
        }
        setState(() { _eleves = elevesData; _isLoading = false; });
      } else {
        _showSnack(response['message'] ?? 'Erreur', isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack('Erreur de connexion', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConduites() async {
    if (_selectedClasseId == null) return;
    setState(() => _isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final conduitesData = <Map<String, dynamic>>[];
      for (var e in _eleves) {
        final id = e['id'] as int;
        final noteText = _noteControllers[id]?.text ?? '';
        final appreciation = _appreciationControllers[id]?.text ?? '';
        if (noteText.isNotEmpty || appreciation.isNotEmpty) {
          conduitesData.add({'eleve_id': id, 'note': noteText.isNotEmpty ? double.tryParse(noteText) : null, 'appreciation': appreciation});
        }
      }
      final response = await api.storeConduites(classeId: _selectedClasseId!, trimestre: _selectedTrimestre, conduites: conduitesData);
      if (response['success'] == true && mounted) {
        _showSnack(response['message'] ?? 'Enregistré', isError: false);
      } else {
        _showSnack(response['message'] ?? 'Erreur', isError: true);
      }
    } catch (e) {
      _showSnack('Erreur de connexion', isError: true);
    } finally {
      setState(() => _isLoading = false);
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
        title: 'Note de Conduite',
        subtitle: className.isNotEmpty ? className : 'Saisie des notes comportementales',
        showBack: true,
        actions: [
          if (_eleves.isNotEmpty)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded, color: Colors.white),
              onPressed: _isLoading ? null : _saveConduites,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _eleves.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.assignment_ind_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun élève ou accès non autorisé\n(Seul le professeur principal peut gérer la conduite)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                          ),
                        ]),
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
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int>(
              value: _selectedClasseId,
              decoration: InputDecoration(
                labelText: 'Classe',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                prefixIcon: const Icon(Icons.class_rounded, color: AppTheme.primary, size: 20),
              ),
              items: widget.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.displayName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) { setState(() => _selectedClasseId = v); _loadConduites(); },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedTrimestre,
              decoration: InputDecoration(
                labelText: 'Trimestre',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
              ),
              items: [1, 2, 3].map((t) => DropdownMenuItem(value: t, child: Text('T$t'))).toList(),
              onChanged: (v) { setState(() => _selectedTrimestre = v!); _loadConduites(); },
            ),
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
        final id = eleve['id'] as int;
        final hasExisting = (eleve['note'] != null && eleve['note'].toString().isNotEmpty) ||
            (eleve['appreciation'] != null && eleve['appreciation'].toString().isNotEmpty);
        final initials = '${eleve['nom'][0]}${eleve['prenom'][0]}'.toUpperCase();
        final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
        final color = colors[index % colors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withAlpha(180)]), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${eleve['nom']} ${eleve['prenom']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                  Text('Matricule: ${eleve['matricule'] ?? '-'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ])),
                if (hasExisting)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.success.withAlpha(20), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Saisi', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _noteControllers[id],
                    enabled: !hasExisting,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Note /20',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2)),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _appreciationControllers[id],
                    enabled: !hasExisting,
                    decoration: InputDecoration(
                      labelText: 'Appréciation',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: 2)),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}
