import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/pdf_service.dart';

class PaiementsScreen extends StatefulWidget {
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
    _fetchPaiementsData();
  }

  Future<void> _fetchPaiementsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userStr = prefs.getString('user');
      if (userStr != null) {
        try {
          final userJson = json.decode(userStr);
          if (userJson['nom'] != null) {
            _profName = '${userJson['prenom'] ?? ''} ${userJson['nom']}'.trim();
          }
        } catch (_) {}
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/professeur/mes-paiements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paiements = data['paiements'] ?? [];
          _heuresNonPayees = data['heures_non_payees'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des paiements')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mes Paiements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green)))
          : RefreshIndicator(
              onRefresh: _fetchPaiementsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeuresCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Historique des Fiches de Paie',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_paiements.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('Aucune fiche de paie générée',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._paiements.map((p) => _buildPaiementCard(p)).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeuresCard() {
    if (_heuresNonPayees == null) return const SizedBox.shrink();

    final totalHeures = _heuresNonPayees!['total_heures'] ?? 0;
    final montantEstime = _heuresNonPayees!['montant_estime'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.teal[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Heures Effectuées (Non payées)',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.timer, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$totalHeures h',
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Est. ${montantEstime} FCFA',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Basé sur les heures enregistrées dans votre cahier de texte ce mois-ci.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPaiementCard(dynamic paiement) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.payments, color: Colors.green[700]),
        ),
        title: Text(
          'Mois: ${paiement['mois']} / ${paiement['annee']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Heures validées: ${paiement['total_heures']} h'),
            const SizedBox(height: 4),
            Text(
              'Statut: ${paiement['statut'] == 'paye' ? 'Payé' : 'En attente'}',
              style: TextStyle(
                color:
                    paiement['statut'] == 'paye' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${paiement['montant_total']} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.download, color: Colors.blue[600], size: 20),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Génération de la fiche de paie...')),
          );
          PdfService.generateAndDownloadFicheDePaie(
            paiement: paiement,
            profName: _profName,
          ).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur: $error')),
            );
          });
        },
      ),
    );
  }
}
