import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/pdf_service.dart';
import '../widgets/premium_app_bar.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  _PaiementsScreenState createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  bool _isLoading = true;
  List<dynamic> _paiements = [];
  Map<String, dynamic>? _heuresNonPayees;
  String _profName = 'Professeur';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.tokenKey);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/professeur/mes-paiements'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paiements = data['paiements'] ?? [];
          _heuresNonPayees = data['heures_non_payees'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) _showSnack('Erreur de chargement', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showSnack('Erreur de connexion', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Mes Paiements',
        subtitle: 'Historique des fiches de paie',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetch,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _fetch,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_heuresNonPayees != null) _buildHeuresCard(),
                    const SizedBox(height: 28),

                    // Section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF2563EB)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text('Fiches de Paie', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.primary.withAlpha(15), borderRadius: BorderRadius.circular(20)),
                          child: Text('${_paiements.length} fiche${_paiements.length > 1 ? 's' : ''}',
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_paiements.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Aucune fiche de paie générée', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 16)),
                        ]),
                      ))
                    else
                      ..._paiements.map(_buildPaiementCard),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeuresCard() {
    final totalHeures = _heuresNonPayees!['total_heures'] ?? 0;
    final montantEstime = _heuresNonPayees!['montant_estime'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.success.withAlpha(70), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Heures Non Payées', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.timer_rounded, color: Colors.white, size: 18)),
          ]),
          const SizedBox(height: 10),
          Text('$totalHeures h', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Estimation : $montantEstime FCFA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 10),
          const Text('Basé sur les heures du cahier de texte ce mois-ci', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPaiementCard(dynamic p) {
    final isPaid = p['statut'] == 'paye';
    final statusColor = isPaid ? AppTheme.success : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showSnack('Génération de la fiche de paie...', isError: false);
          PdfService.generateAndDownloadFicheDePaie(paiement: p, profName: _profName).catchError((_) {
            if (mounted) _showSnack('Erreur lors de la génération', isError: true);
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.success.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.payments_rounded, color: AppTheme.success, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mois ${p['mois']} / ${p['annee']}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text('${p['heures_travaillees'] ?? 0} h validées',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withAlpha(15), borderRadius: BorderRadius.circular(20)),
                  child: Text(isPaid ? '✓ Payé' : '⏳ En attente',
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${p['montant_total']} F', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                const Icon(Icons.download_rounded, color: AppTheme.primary, size: 18),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
