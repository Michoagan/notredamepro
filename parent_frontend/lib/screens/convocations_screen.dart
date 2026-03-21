import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../models/eleve.dart';
import '../utils/theme.dart';
import '../widgets/enfant_selector.dart';

class ConvocationsScreen extends StatefulWidget {
  final List<Eleve> enfants;
  final Eleve initialEleve;

  const ConvocationsScreen({
    super.key,
    required this.enfants,
    required this.initialEleve,
  });

  @override
  State<ConvocationsScreen> createState() => _ConvocationsScreenState();
}

class _ConvocationsScreenState extends State<ConvocationsScreen> {
  late Eleve _selectedEleve;
  bool _isLoading = false;
  List<dynamic> _convocations = [];

  @override
  void initState() {
    super.initState();
    _selectedEleve = widget.initialEleve;
    _fetchConvocations();
  }

  Future<void> _fetchConvocations() async {
    setState(() => _isLoading = true);
    final apiService = Provider.of<ApiService>(context, listen: false);
    final data = await apiService.getConvocations(_selectedEleve.id);

    if (mounted) {
      if (data != null && data['success'] == true) {
        setState(() {
          _convocations = data['sessions'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _convocations = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDownloadConvocation(Map<String, dynamic> session) async {
    final pdfBytes = await PdfService.generateConvocationPdf(
      eleve: _selectedEleve.toJson(),
      session: session,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'convocation_${_selectedEleve.nom}_${session['session_nom']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Convocations & Devoirs'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sélecteur d'enfant
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: EnfantSelectorWidget(
              enfants: widget.enfants,
              selectedEnfant: _selectedEleve,
              onEnfantSelected: (eleve) {
                if (eleve.id != _selectedEleve.id) {
                  setState(() {
                    _selectedEleve = eleve;
                  });
                  _fetchConvocations();
                }
              },
            ),
          ),

          // Liste des convocations
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _convocations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _convocations.length,
                    itemBuilder: (context, index) {
                      final session = _convocations[index];
                      return _buildConvocationCard(session);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune composition prévue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pas de convocations disponibles pour l\'instant.',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConvocationCard(Map<String, dynamic> session) {
    final bool isDownloadable = session['is_downloadable'] ?? false;
    final int tempsRestant = session['temps_restant_jours'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session['session_nom'] ?? 'Session',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDownloadable
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDownloadable ? 'Disponible' : 'Bientôt',
                    style: TextStyle(
                      color: isDownloadable
                          ? AppTheme.success
                          : AppTheme.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Début : ${session['date_debut'] ?? 'Inconnue'}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (!isDownloadable && tempsRestant > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_rounded,
                      size: 16,
                      color: AppTheme.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Convocation téléchargeable dans $tempsRestant jour(s)',
                      style: const TextStyle(
                        color: AppTheme.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isDownloadable
                    ? () => _handleDownloadConvocation(session)
                    : null,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Télécharger la Convocation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
