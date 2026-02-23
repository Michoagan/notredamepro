import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../widgets/enfant_selector.dart';
import 'package:printing/printing.dart';

class FinancesScreen extends StatefulWidget {
  final List<Eleve> enfants;
  final Eleve initialEleve;

  const FinancesScreen({
    super.key,
    required this.enfants,
    required this.initialEleve,
  });

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  late Eleve _selectedEleve;

  @override
  void initState() {
    super.initState();
    _selectedEleve = widget.initialEleve;
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Finances', style: TextStyle(fontSize: 16)),
            Text(
              _selectedEleve.prenom,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          if (widget.enfants.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              child: EnfantSelectorWidget(
                enfants: widget.enfants,
                selectedEnfant: _selectedEleve,
                onEnfantSelected: (enfant) {
                  if (_selectedEleve.id != enfant.id) {
                    setState(() {
                      _selectedEleve = enfant;
                    });
                  }
                },
              ),
            ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: apiService.getPaiements(_selectedEleve.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Impossible de charger les données financières.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                double _parseDouble(dynamic value) {
                  if (value == null) return 0.0;
                  if (value is num) return value.toDouble();
                  if (value is String) return double.tryParse(value) ?? 0.0;
                  return 0.0;
                }

                final contribution = _parseDouble(data['contribution']);
                final paiements = (data['paiements'] as List<dynamic>?) ?? [];

                double totalPaye = 0.0;
                for (var p in paiements) {
                  if (p['statut'] == 'success') {
                    totalPaye += _parseDouble(p['montant']);
                  }
                }

                final soldeRestant = contribution - totalPaye;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(
                        context,
                        soldeRestant >= 0 ? soldeRestant : 0.0,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Mes Échéances',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEcheancesList(soldeRestant),
                      const SizedBox(height: 32),
                      Text(
                        'Derniers Paiements',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoriqueList(paiements),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double soldeRestant) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Solde Restant à Payer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${soldeRestant.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              color: AppTheme.accent, // Gold accent for money
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                // Action pour initier un paiement KkiaPay / Fedapay
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.payment_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Intégration du portail de paiement en cours...',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.primaryDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.credit_card_rounded,
                color: AppTheme.primaryDark,
              ),
              label: const Text(
                'EFFECTUER UN PAIEMENT',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent, // Gold button!
                shadowColor: AppTheme.accent.withValues(alpha: 0.5),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcheancesList(double soldeRestant) {
    if (soldeRestant <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.verified_rounded, color: AppTheme.success, size: 48),
            SizedBox(height: 12),
            Text(
              'Félicitations, vous êtes en règle !',
              style: TextStyle(
                color: AppTheme.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.warning,
          ),
        ),
        title: const Text(
          'Scolarité en cours',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Restant à honorer: ${soldeRestant.toStringAsFixed(0)} FCFA',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriqueList(List<dynamic> paiements) {
    if (paiements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun paiement récent.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paiements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = paiements[index];

        double _parseDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is num) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        final montant = _parseDouble(p['montant']);
        final statut = p['statut'] ?? 'inconnu';
        final isSuccess = statut == 'success';

        final dateString = p['date_paiement'] ?? p['created_at'] ?? '';
        final date = dateString.isNotEmpty
            ? (dateString as String).substring(0, 10)
            : 'N/C';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isSuccess ? AppTheme.success : AppTheme.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isSuccess ? AppTheme.success : AppTheme.error,
              ),
            ),
            title: Text(
              'Paiement via ${p['methode'] ?? 'N/C'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: $date\nStatut: ${statut.toUpperCase()}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (isSuccess) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final apiService = Provider.of<ApiService>(
                          context,
                          listen: false,
                        );

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          ),
                        );

                        final pdfBytes = await apiService.getReceiptPdf(
                          p['id'],
                        );

                        // Hide loading indicator
                        if (context.mounted) Navigator.pop(context);

                        if (pdfBytes != null) {
                          await Printing.layoutPdf(
                            onLayout: (format) async => pdfBytes,
                            name: 'Recu_Paiement_${p['id']}.pdf',
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Erreur lors du téléchargement du reçu.',
                                ),
                                backgroundColor: AppTheme.error,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.download_rounded,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Télécharger le reçu',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isSuccess ? AppTheme.success : AppTheme.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${montant.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  color: isSuccess ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
