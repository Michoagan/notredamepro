import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/moyenne.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndDownloadBulletin({
    required List<Moyenne> moyennes,
    required String classeName,
    required String matiereName,
    required int trimestre,
    required String profName,
  }) async {
    final pdf = pw.Document();

    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(classeName, matiereName, trimestre, profName, date),
            pw.SizedBox(height: 20),
            _buildTable(moyennes),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    // Save/Share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'moyennes_${classeName}_T${trimestre}.pdf');
  }

  static pw.Widget _buildHeader(String classeName, String matiereName,
      int trimestre, String profName, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Collège Notre Dame',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: $date'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text('RELEVÉ DE MOYENNES',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Classe: $classeName',
                style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Matière: $matiereName',
                style: const pw.TextStyle(fontSize: 14)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Professeur: $profName',
                style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Trimestre: $trimestre',
                style: const pw.TextStyle(fontSize: 14)),
          ]),
        ]),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildTable(List<Moyenne> moyennes) {
    return pw.TableHelper.fromTextArray(
      headers: ['Rang', 'Nom', 'Prénom', 'Moyenne /20', 'Appréciation'],
      data: moyennes.map((moyenne) {
        return [
          moyenne.rang.toString(),
          moyenne.eleveNom,
          moyenne.elevePrenom,
          (moyenne.moyenneTrimestrielle ?? 0.0).toStringAsFixed(2),
          _getAppreciation(moyenne.moyenneTrimestrielle ?? 0.0),
        ];
      }).toList(),
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        0: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static String _getAppreciation(double note) {
    if (note >= 16) return 'Très Bien';
    if (note >= 14) return 'Bien';
    if (note >= 12) return 'Assez Bien';
    if (note >= 10) return 'Passable';
    if (note >= 8) return 'Insuffisant';
    return 'Faible';
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Généré par NotreDamePro'),
          pw.Text('Signature du professeur: _________________'),
        ]),
      ],
    );
  }

  static Future<void> generateAndDownloadFicheDePaie({
    required Map<String, dynamic> paiement,
    required String profName,
  }) async {
    final pdf = pw.Document();

    final mois = paiement['mois'];
    final annee = paiement['annee'];
    final dateGen = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Build QR Code Data
    final qrData =
        'Fiche de Paie NDPro\nProf: $profName\nMois: $mois/$annee\nTotal: ${paiement['montant_total']} FCFA\nStatut: ${paiement['statut']}\nGénéré le: $dateGen';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Collège Notre Dame',
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800)),
                          pw.Text('Direction des Ressources Humaines',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 20),
                          pw.Text('FICHE DE PAIE',
                              style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Mois validé: $mois / $annee',
                              style: const pw.TextStyle(fontSize: 14)),
                        ]),
                    // Emplacement QR Code
                    pw.Container(
                      width: 80,
                      height: 80,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrData,
                        color: PdfColors.black,
                      ),
                    )
                  ]),

              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Prof Info
              pw.Text('Informations de l\'Employé',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(5)),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Row(children: [
                    pw.Text('Nom & Prénom(s) : ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(profName),
                  ])),

              pw.SizedBox(height: 30),

              // Détails Paie
              pw.Text('Détails de Rémunération',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('Désignation',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('Montant (FCFA)',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right)),
                        ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              'Heures validées (${paiement['total_heures']} h)')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${paiement['montant_heures']}',
                              textAlign: pw.TextAlign.right)),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Primes & Indemnités')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${paiement['montant_primes']}',
                              textAlign: pw.TextAlign.right)),
                    ]),
                    pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.green50),
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('SALAIRE NET À PAYER',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.green800))),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text('${paiement['montant_total']}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.green800),
                                  textAlign: pw.TextAlign.right)),
                        ])
                  ]),

              pw.SizedBox(height: 40),

              // Signatures
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text('L\'Employé(e)',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 60),
                          pw.Text('_______________________')
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text('La Direction / Comptabilité',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 60),
                          pw.Text('_______________________')
                        ])
                  ]),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                  child: pw.Text(
                      'Ce document numérique est certifié par NotreDamePro. Scannez le QR Code pour vérifier l\'authenticité.',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.center))
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Fiche_Paie_${profName}_${mois}_${annee}.pdf');
  }
}
