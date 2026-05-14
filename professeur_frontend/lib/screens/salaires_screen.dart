import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/pdf_service.dart';
import '../widgets/premium_app_bar.dart';

class SalairesScreen extends StatefulWidget {
  const SalairesScreen({super.key});

  @override
  _SalairesScreenState createState() => _SalairesScreenState();
}

class _SalairesScreenState extends State<SalairesScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _salaires = [];
  Map<String, dynamic>? _heuresNonPayees;
  String _profName = 'Professeur';
  bool _isLoading = true;
  String _error = '';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Noms des mois en français
  static const List<String> _moisNoms = [
    '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fetchSalaires();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  /// Convertit un numéro de mois en nom lisible
  String _formatMois(dynamic mois, dynamic annee) {
    final int? m = int.tryParse(mois.toString());
    final String anneeStr = annee?.toString() ?? '';
    if (m != null && m >= 1 && m <= 12) {
      return '${_moisNoms[m]} $anneeStr'.trim();
    }
    return mois?.toString() ?? 'N/A';
  }

  Future<void> _fetchSalaires() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final token =
          await const FlutterSecureStorage().read(key: AppConstants.tokenKey);
      final resp = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mesPaiements}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['success'] == true) {
          setState(() {
            _salaires = data['paiements'] ?? [];
            _heuresNonPayees = data['heures_non_payees'];
            if (data['professeur'] != null) {
              final p = data['professeur'];
              _profName =
                  '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim();
              if (_profName.isEmpty) _profName = 'Professeur';
            }
            _isLoading = false;
          });
          _fadeCtrl.forward();
          return;
        }
      }
      setState(() {
        _error = 'Erreur lors du chargement (${resp.statusCode})';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion';
        _isLoading = false;
      });
    }
  }

  Future<void> _accuseReception(int salaireId) async {
    if (!mounted) return;
    try {
      final token =
          await const FlutterSecureStorage().read(key: AppConstants.tokenKey);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      );
      final resp = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.accusePaiement}/$salaireId/accuse'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );
      if (mounted) Navigator.of(context).pop();
      if (resp.statusCode == 200) {
        _showSnack('Accusé de réception envoyé ✓', AppTheme.success);
        _fetchSalaires();
      } else {
        _showSnack('Erreur lors de la confirmation', AppTheme.error);
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnack('Erreur de connexion', AppTheme.error);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: PremiumAppBar(
        title: 'Mes Paiements',
        subtitle: _salaires.isEmpty
            ? null
            : '${_salaires.length} bulletin(s)',
        actions: [
          PremiumActionBtn(
            icon: Icons.refresh_rounded,
            onTap: _fetchSalaires,
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2.5)))
          else if (_error.isNotEmpty)
            SliverFillRemaining(child: _buildError())
          else if (_salaires.isEmpty && _heuresNonPayees == null)
            SliverFillRemaining(child: _buildEmpty())
          else ...[
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildHeuresCard(),
                  const SizedBox(height: 16),
                  _buildSummaryBanner(),
                  const SizedBox(height: 24),
                  if (_salaires.isNotEmpty)
                    const Text(
                      'Historique des bulletins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            if (_salaires.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildSalaireCard(_salaires[i], i),
                    ),
                    childCount: _salaires.length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tableau de Bord',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gestion des salaires et bulletins',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHeuresCard() {
    if (_heuresNonPayees == null) return const SizedBox.shrink();

    final totalHeures = (_heuresNonPayees!['total_heures'] ?? 0);
    final montantEstime =
        (_heuresNonPayees!['montant_estime'] ?? 0).toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Heures en cours (Non payées)',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.pending_actions, color: AppTheme.warning, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$totalHeures h',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calculate, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Estimation : ${montantEstime.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner() {
    if (_salaires.isEmpty) return const SizedBox.shrink();
    double total = 0;
    int nonAccuses = 0;
    for (final s in _salaires) {
      total += (s['montant_total'] ?? s['montant'] ?? 0).toDouble();
      if (s['accuse_reception'] != true) nonAccuses++;
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'Total Reçu',
            value: '${total.toStringAsFixed(0)} F',
            icon: Icons.check_circle_outline,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiCard(
            title: 'Non Accusés',
            value: '$nonAccuses',
            icon: Icons.notifications_active_outlined,
            color: nonAccuses > 0 ? AppTheme.warning : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaireCard(dynamic s, int index) {
    final bool accuse = s['accuse_reception'] == true;
    final String moisLabel = _formatMois(s['mois'], s['annee']);
    final double montant = (s['montant_total'] ?? s['montant'] ?? 0).toDouble();
    final double totalHeures = (s['total_heures'] ?? s['heures_travaillees'] ?? 0).toDouble();
    final String statut = s['statut'] ?? 'payé';
    final bool estPaye = statut == 'paye' || statut == 'payé';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: accuse ? AppTheme.success.withOpacity(0.5) : AppTheme.surfaceBorder,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accuse ? AppTheme.success.withOpacity(0.12) : AppTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    accuse ? Icons.check_circle : Icons.receipt_long,
                    color: accuse ? AppTheme.success : AppTheme.gold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moisLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _badge(estPaye ? 'Payé' : 'En attente', estPaye ? AppTheme.success : AppTheme.warning),
                          if (accuse) _badge('Accusé', AppTheme.success),
                          if (totalHeures > 0) _badge('${totalHeures.toStringAsFixed(1)} h', AppTheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      montant.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'FCFA',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generatePdf(s),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Bulletin PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
                if (!accuse) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _accuseReception(s['id']),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Accuser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(_error, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSalaires,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Aucun paiement trouvé',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos bulletins de salaire apparaîtront ici',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSalaires,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(dynamic s) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
    );
    try {
      await PdfService.generateAndDownloadFicheDePaie(
        paiement: Map<String, dynamic>.from(s),
        profName: _profName,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnack('Erreur lors de la génération du PDF', AppTheme.error);
      }
    }
  }
}
