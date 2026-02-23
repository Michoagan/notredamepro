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
}
