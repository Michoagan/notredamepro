import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/eleve.dart';
import '../models/classe.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.getDashboardData();
      if (mounted) {
        setState(() {
          if (data['success'] == true) {
            _classes = (data['classes'] as List<Classe>?) ?? [];
            if (_classes.isNotEmpty) {
              _selectedClasseId = _classes.first.id;
              _loadEleves(_selectedClasseId!);
            } else {
              _isLoading = false;
            }
          } else {
            _errorMessage = 'Erreur lors du chargement';
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Erreur de connexion'; _isLoading = false; });
    }
  }

  Future<void> _loadEleves(int classeId) async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final result = await api.getElevesByClasse(classeId);
      if (mounted) setState(() { _eleves = result; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _errorMessage = 'Erreur lors du chargement'; _isLoading = false; });
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'appeler $phone')));
    }
  }

  List<Eleve> get _filteredEleves {
    if (_searchQuery.isEmpty) return _eleves;
    final q = _searchQuery.toLowerCase();
    return _eleves.where((e) => '${e.nom} ${e.prenom}'.toLowerCase().contains(q) || (e.nomTuteur?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final className = _selectedClasseId != null && _classes.isNotEmpty
        ? _classes.firstWhere((c) => c.id == _selectedClasseId, orElse: () => _classes.first).displayName
        : '';
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Contacts Parents',
        subtitle: className.isNotEmpty ? className : 'Annuaire des tuteurs',
        showBack: true,
      ),
      body: Column(
        children: [
          // Filter + Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(children: [
              DropdownButtonFormField<int>(
                value: _selectedClasseId,
                decoration: InputDecoration(
                  labelText: 'Classe',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                  prefixIcon: const Icon(Icons.class_rounded, color: AppTheme.primary, size: 20),
                ),
                items: _classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.displayName, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _selectedClasseId = v); _loadEleves(v); } },
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher un élève ou parent...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
                ),
              ),
            ]),
          ),

          // Stats bar
          if (!_isLoading && _eleves.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppTheme.background,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.primary.withAlpha(15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_filteredEleves.length} élève${_filteredEleves.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.success.withAlpha(15), borderRadius: BorderRadius.circular(20)),
                  child: Text('${_filteredEleves.where((e) => e.telephoneTuteur?.isNotEmpty == true).length} contacts',
                      style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ]),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _errorMessage != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _selectedClasseId != null ? _loadEleves(_selectedClasseId!) : _loadClasses(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ]))
                    : _filteredEleves.isEmpty
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Aucun résultat', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                          ]))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _filteredEleves.length,
                            itemBuilder: (context, index) {
                              final eleve = _filteredEleves[index];
                              final hasParent = eleve.nomTuteur?.isNotEmpty == true;
                              final hasPhone = eleve.telephoneTuteur?.isNotEmpty == true;
                              final initials = eleve.nom.substring(0, 1).toUpperCase();
                              final colors = [const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFF10B981), const Color(0xFFF59E0B)];
                              final color = colors[index % colors.length];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withAlpha(180)]), borderRadius: BorderRadius.circular(14)),
                                        child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                                      ),
                                      const SizedBox(width: 14),
                                      // Info
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('${eleve.nom} ${eleve.prenom}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          Icon(Icons.family_restroom_rounded, size: 14, color: hasParent ? AppTheme.textSecondary : Colors.grey.shade300),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(
                                            hasParent ? eleve.nomTuteur! : 'Parent non renseigné',
                                            style: TextStyle(fontSize: 12, color: hasParent ? AppTheme.textSecondary : Colors.grey.shade400, fontStyle: hasParent ? FontStyle.normal : FontStyle.italic),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                        ]),
                                        if (hasPhone) ...[
                                          const SizedBox(height: 3),
                                          Row(children: [
                                            Icon(Icons.phone_rounded, size: 14, color: AppTheme.success),
                                            const SizedBox(width: 4),
                                            Text(eleve.telephoneTuteur!, style: const TextStyle(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w600)),
                                          ]),
                                        ],
                                      ])),
                                      // Call button
                                      if (hasPhone)
                                        GestureDetector(
                                          onTap: () => _call(eleve.telephoneTuteur!),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [BoxShadow(color: AppTheme.success.withAlpha(60), blurRadius: 8, offset: const Offset(0, 4))],
                                            ),
                                            child: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                                          child: Icon(Icons.phone_disabled_rounded, color: Colors.grey.shade400, size: 22),
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
