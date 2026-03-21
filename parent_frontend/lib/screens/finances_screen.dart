import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../models/eleve.dart';
import '../services/api_service.dart';
import '../widgets/enfant_selector.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

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

                final isPaiementEnLigneActif =
                    data['paiement_en_ligne_actif'] == true ||
                    data['paiement_en_ligne_actif'] == 'true';

                double totalPaye = 0.0;
                // Filter the list to only include 'success' array items
                final successfulPaiements = paiements
                    .where((p) => p['statut'] == 'success')
                    .toList();

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
                        isPaiementEnLigneActif,
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
                      _buildHistoriqueList(successfulPaiements),
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

  Widget _buildBalanceCard(
    BuildContext context,
    double soldeRestant,
    bool onlineActive,
  ) {
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
          if (onlineActive) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showPaymentModal(context, soldeRestant, _selectedEleve.id);
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
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les paiements en ligne sont temporairement désactivés par la direction. Veuillez vous rapprocher de la comptabilité.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

                        // Generate PDF natively
                        final font = await PdfGoogleFonts.openSansRegular();
                        final fontBold = await PdfGoogleFonts.openSansBold();

                        final pdf = pw.Document(
                          theme: pw.ThemeData.withFont(
                            base: font,
                            bold: fontBold,
                          ),
                        );

                        pdf.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat.a4,
                            build: (pw.Context context) {
                              return pw.Container(
                                padding: const pw.EdgeInsets.all(30),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Header(
                                      level: 0,
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(
                                            'REÇU DE PAIEMENT',
                                            style: pw.TextStyle(
                                              fontSize: 24,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blue900,
                                            ),
                                          ),
                                          pw.Text(
                                            'NDTG',
                                            style: pw.TextStyle(
                                              fontSize: 20,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    pw.SizedBox(height: 20),
                                    pw.Text(
                                      'Informations de l\'élève',
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Divider(),
                                    pw.Text('Nom: ${_selectedEleve.nom}'),
                                    pw.Text('Prénom: ${_selectedEleve.prenom}'),
                                    pw.Text(
                                      'Matricule: ${_selectedEleve.matricule}',
                                    ),
                                    pw.SizedBox(height: 20),
                                    pw.Text(
                                      'Détails du Paiement',
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Divider(),
                                    pw.Text(
                                      'Référence: ${p['reference_externe'] ?? p['reference'] ?? 'N/A'}',
                                    ),
                                    pw.Text(
                                      'Montant: ${montant.toStringAsFixed(0)} FCFA',
                                    ),
                                    pw.Text('Date: $date'),
                                    pw.Text(
                                      'Méthode: ${p['methode'] ?? 'N/A'}',
                                    ),
                                    pw.Text(
                                      'Statut: Payé',
                                      style: pw.TextStyle(
                                        color: PdfColors.green700,
                                      ),
                                    ),
                                    pw.SizedBox(height: 40),
                                    pw.Center(
                                      child: pw.BarcodeWidget(
                                        color: PdfColors.black,
                                        barcode: pw.Barcode.qrCode(),
                                        data:
                                            '{"recu_id":${p['id']},"reference":"${p['reference_externe'] ?? p['reference'] ?? ''}","eleve":"${_selectedEleve.nom} ${_selectedEleve.prenom}","montant":$montant,"date":"$date","statut":"Payé"}',
                                        width: 150,
                                        height: 150,
                                      ),
                                    ),
                                    pw.SizedBox(height: 20),
                                    pw.Center(
                                      child: pw.Text(
                                        'Document généré le ${DateTime.now().toString().substring(0, 16)}',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );

                        final pdfBytes = await pdf.save();

                        // Hide loading indicator
                        if (context.mounted) Navigator.pop(context);

                        await Printing.sharePdf(
                          bytes: pdfBytes,
                          filename: 'Recu_Paiement_${p['id']}.pdf',
                        );
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

  void _showPaymentModal(BuildContext context, double maxAmount, int eleveId) {
    if (maxAmount <= 0) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PaymentModal(maxAmount: maxAmount, eleveId: eleveId);
      },
    );
  }
}

class _PaymentModal extends StatefulWidget {
  final double maxAmount;
  final int eleveId;

  const _PaymentModal({required this.maxAmount, required this.eleveId});

  @override
  State<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<_PaymentModal> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'fedapay'; // default
  bool _isProcessing = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() {
      _isProcessing = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    final response = await apiService.processPayment(
      amount,
      _paymentMethod,
      widget.eleveId,
      widget.maxAmount,
    );

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      Navigator.pop(context); // Close the modal
    }

    if (response != null && response['success'] == true) {
      // Logic to launch URL or config
      if (response['payment_url'] != null) {
        final url = response['payment_url'];
        _launchUrl(url);
      } else if (response['kkiapay_config'] != null) {
        // KkiaPay is currently only returning config for Javascript.
        // We will notify the user or use a WebView mechanism.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'KkiaPay n\'est pas encore disponible dans l\'application native.',
            ),
          ),
        );
      }
    } else {
      final msg = response != null ? response['message'] : 'Erreur réseau.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir la page: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Effectuer un Paiement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant à payer (FCFA)',
                hintText: 'Max: ${widget.maxAmount.toStringAsFixed(0)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.money),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Entrez un montant';
                final val = double.tryParse(v);
                if (val == null || val < 1000)
                  return 'Montant minimum 1000 FCFA';
                if (val > widget.maxAmount) return 'Dépasse le solde restant';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'Moyen de paiement',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'fedapay',
                  child: Text('FedaPay (Carte / Mobile Money)'),
                ),
                DropdownMenuItem(
                  value: 'kkiapay',
                  child: Text('KkiaPay (Mobile Money)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'PAYER MAINTENANT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
