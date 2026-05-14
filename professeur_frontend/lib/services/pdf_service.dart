import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/moyenne.dart';
import 'package:intl/intl.dart';

// ─── Couleurs du thème NDTG ──────────────────────────────────
const _kPrimary   = PdfColor.fromInt(0xFF1A237E); // Bleu nuit
const _kPrimaryL  = PdfColor.fromInt(0xFF3949AB); // Indigo
const _kGold      = PdfColor.fromInt(0xFFF59E0B); // Or
const _kSuccess   = PdfColor.fromInt(0xFF059669); // Vert
const _kError     = PdfColor.fromInt(0xFFDC2626); // Rouge
const _kTextDark  = PdfColor.fromInt(0xFF1E293B); // Slate 800
const _kTextGrey  = PdfColor.fromInt(0xFF64748B); // Slate 500
const _kBg        = PdfColor.fromInt(0xFFF8FAFC); // Fond léger
const _kLine      = PdfColor.fromInt(0xFFE2E8F0); // Bordure

// ─── Helpers ─────────────────────────────────────────────────
String _n(double? v) => v == null ? '-' : v.toStringAsFixed(2);
String _appre(double? v) {
  if (v == null) return '-';
  if (v >= 16) return 'Tres Bien';
  if (v >= 14) return 'Bien';
  if (v >= 12) return 'A. Bien';
  if (v >= 10) return 'Passable';
  if (v >= 8)  return 'Insuffis.';
  return 'Faible';
}
PdfColor _appreColor(double? v) {
  if (v == null) return _kTextGrey;
  if (v >= 16) return PdfColor.fromInt(0xFF059669);
  if (v >= 14) return PdfColor.fromInt(0xFF0891B2);
  if (v >= 12) return PdfColor.fromInt(0xFF7C3AED);
  if (v >= 10) return PdfColor.fromInt(0xFFD97706);
  if (v >= 8)  return PdfColor.fromInt(0xFFEA580C);
  return PdfColor.fromInt(0xFFDC2626);
}
PdfColor _noteColor(double? v) {
  if (v == null) return _kTextGrey;
  if (v >= 10) return _kSuccess;
  return _kError;
}

class PdfService {
  // ═══════════════════════════════════════════════════════════
  //  BULLETIN — RELEVÉ DE MOYENNES
  // ═══════════════════════════════════════════════════════════
  static Future<void> generateAndDownloadBulletin({
    required List<Moyenne> moyennes,
    required String classeName,
    required String matiereName,
    required int trimestre,
    required String profName,
    int totalEvalues = 0,
    int nombreReussite = 0,
    int nombreEchec = 0,
    double pourcentageReussite = 0,
    double pourcentageEchec = 0,
    double moyenneGeneraleClasse = 0,
  }) async {
    final pdf = pw.Document();
    final logoData = await rootBundle.load('assets/images/logopdf.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final now  = DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      build: (ctx) => [
        _bulletinHeader(logoImage, classeName, matiereName, trimestre, profName, date),
        pw.SizedBox(height: 12),
        if (totalEvalues > 0) ...[
          _statsBar(totalEvalues, nombreReussite, nombreEchec,
              pourcentageReussite, pourcentageEchec, moyenneGeneraleClasse),
          pw.SizedBox(height: 14),
        ],
        _bulletinTable(moyennes),
        pw.SizedBox(height: 24),
        _bulletinSignatures(),
        pw.SizedBox(height: 16),
        _pdfFooter(now),
      ],
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Releve_Moyennes_${classeName}_T$trimestre.pdf',
    );
  }

  static pw.Widget _bulletinHeader(
    pw.MemoryImage logo, String classe, String matiere,
    int trimestre, String prof, String date,
  ) {
    return pw.Column(children: [
      // Bandeau bleu top
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const pw.BoxDecoration(
          color: _kPrimary,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Logo
            pw.Container(
              width: 70, height: 70,
              decoration: const pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
              padding: const pw.EdgeInsets.all(4),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            // Titre
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.Text('COLLÈGE NOTRE DAME DE TOUTES GRÂCES',
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.SizedBox(height: 4),
              pw.Text('RELEVÉ DE MOYENNES',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _kGold, letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: _kGold, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20))),
                child: pw.Text('TRIMESTRE $trimestre',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kPrimary)),
              ),
            ]),
            // Date
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('Date d\'édition', style: const pw.TextStyle(fontSize: 8, color: PdfColor(1, 1, 1, 0.6))),
              pw.Text(date, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ]),
          ],
        ),
      ),
      pw.SizedBox(height: 10),
      // Infos classe / prof
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _kBg,
          border: pw.Border.all(color: _kLine),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _infoChip('Classe', classe),
            _infoChip('Matière', matiere),
            _infoChip('Professeur', prof),
            _infoChip('Trimestre', 'T$trimestre'),
          ],
        ),
      ),
    ]);
  }

  static pw.Widget _infoChip(String label, String value) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _kTextGrey)),
      pw.SizedBox(height: 2),
      pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kTextDark)),
    ]);
  }

  static pw.Widget _statsBar(int total, int reussite, int echec,
      double pReussite, double pEchec, double moyClasse) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _kLine),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly, children: [
        _statCell('Effectif', '$total', _kPrimary),
        _statDivider(),
        _statCell('Moy. Classe', moyClasse.toStringAsFixed(2), _noteColor(moyClasse)),
        _statDivider(),
        _statCell('Réussite', '$reussite (${pReussite.toStringAsFixed(0)}%)', _kSuccess),
        _statDivider(),
        _statCell('Échec', '$echec (${pEchec.toStringAsFixed(0)}%)', _kError),
      ]),
    );
  }

  static pw.Widget _statCell(String label, String value, PdfColor color) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _kTextGrey)),
      pw.SizedBox(height: 3),
      pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
    ]);
  }

  static pw.Widget _statDivider() =>
      pw.Container(width: 1, height: 30, color: _kLine);

  /// Cellule Appréciation avec badge coloré
  static pw.Widget _apprCell(double? moy, PdfColor rowBg) {
    if (moy == null) {
      return pw.Container(
        color: rowBg,
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        alignment: pw.Alignment.center,
        child: pw.Text('-', style: const pw.TextStyle(fontSize: 7, color: _kTextGrey)),
      );
    }
    final label = _appre(moy);
    final color = _appreColor(moy);
    return pw.Container(
      color: rowBg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: pw.BoxDecoration(color: color, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
        child: pw.Text(label,
            style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            maxLines: 1),
      ),
    );
  }

  static pw.Widget _bulletinTable(List<Moyenne> moyennes) {
    final headers = [

      'Rg', 'Nom', 'Prénom',
      'I1', 'I2', 'I3', 'I4', 'M.Int',
      'D1', 'D2',
      'Moy./20', 'Coef', 'M.Coef', 'Appréciation',
    ];
    final widths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(22),
      1: const pw.FlexColumnWidth(2.0),
      2: const pw.FlexColumnWidth(2.0),
      3: const pw.FixedColumnWidth(26),
      4: const pw.FixedColumnWidth(26),
      5: const pw.FixedColumnWidth(26),
      6: const pw.FixedColumnWidth(26),
      7: const pw.FixedColumnWidth(30),
      8: const pw.FixedColumnWidth(26),
      9: const pw.FixedColumnWidth(26),
      10: const pw.FixedColumnWidth(34),
      11: const pw.FixedColumnWidth(24),
      12: const pw.FixedColumnWidth(34),
      13: const pw.FixedColumnWidth(52),
    };

    pw.Widget cell(String text, {PdfColor? bg, PdfColor? fg, bool bold = false, pw.Alignment? align}) =>
        pw.Container(
          color: bg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
          alignment: align ?? pw.Alignment.centerLeft,
          child: pw.Text(text,
              style: pw.TextStyle(fontSize: 7, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: fg ?? _kTextDark),
              maxLines: 2),
        );

    pw.TableRow headerRow = pw.TableRow(
      decoration: const pw.BoxDecoration(color: _kPrimary),
      children: headers.map((h) => cell(h, fg: PdfColors.white, bold: true, align: pw.Alignment.center)).toList(),
    );

    final dataRows = moyennes.asMap().entries.map((entry) {
      final i   = entry.key;
      final m   = entry.value;
      final bg  = i.isEven ? PdfColors.white : _kBg;
      final moy = m.moyenneTrimestrielle;
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: bg),
        children: [
          cell('${m.rang}', bg: bg, align: pw.Alignment.center, bold: true),
          cell(m.eleveNom.toUpperCase(), bg: bg, bold: true),
          cell(m.elevePrenom, bg: bg),
          cell(_n(m.premierInterro), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.premierInterro)),
          cell(_n(m.deuxiemeInterro), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.deuxiemeInterro)),
          cell(_n(m.troisiemeInterro), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.troisiemeInterro)),
          cell(_n(m.quatriemeInterro), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.quatriemeInterro)),
          cell(_n(m.moyenneInterro), bg: bg, align: pw.Alignment.center,
              fg: _noteColor(m.moyenneInterro), bold: true),
          cell(_n(m.premierDevoir), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.premierDevoir)),
          cell(_n(m.deuxiemeDevoir), bg: bg, align: pw.Alignment.center, fg: _noteColor(m.deuxiemeDevoir)),
          cell(moy != null ? '${_n(moy)}/20' : '-',
              bg: moy != null && moy >= 10 ? PdfColor.fromInt(0xFFD1FAE5) : PdfColor.fromInt(0xFFFEE2E2),
              align: pw.Alignment.center, bold: true, fg: _noteColor(moy)),
          cell('${m.coefficient ?? "-"}', bg: bg, align: pw.Alignment.center),
          cell(_n(m.moyenneCoefficientee), bg: bg, align: pw.Alignment.center,
              fg: _noteColor(m.moyenneCoefficientee), bold: true),
          _apprCell(moy, bg),
        ],
      );
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: _kLine, width: 0.5),
      columnWidths: widths,
      children: [headerRow, ...dataRows],
    );
  }

  static pw.Widget _bulletinSignatures() {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      _signBox('Le Professeur'),
      _signBox('Le Chef d\'Établissement'),
      _signBox('Visa Parent / Tuteur'),
    ]);
  }

  static pw.Widget _signBox(String label) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _kLine),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _kPrimary)),
        pw.SizedBox(height: 36),
        pw.Divider(color: _kLine),
        pw.SizedBox(height: 4),
        pw.Text('Signature & Cachet', style: const pw.TextStyle(fontSize: 7, color: _kTextGrey)),
      ]),
    );
  }

  static pw.Widget _pdfFooter(String genDate) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _kPrimary,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('NotreDamePro — Document officiel',
            style: const pw.TextStyle(fontSize: 8, color: PdfColor(1, 1, 1, 0.6))),
        pw.Text('Généré le $genDate',
            style: const pw.TextStyle(fontSize: 8, color: PdfColor(1, 1, 1, 0.6))),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  FICHE DE PAIE
  // ═══════════════════════════════════════════════════════════
  static Future<void> generateAndDownloadFicheDePaie({
    required Map<String, dynamic> paiement,
    required String profName,
  }) async {
    final pdf = pw.Document();
    final logoData = await rootBundle.load('assets/images/logopdf.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    final mois      = paiement['mois'] ?? '-';
    final annee     = paiement['annee'] ?? '-';
    final isPaid    = paiement['statut'] == 'paye';
    final now       = DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now());
    final refNum    = 'NDT-${annee}-${mois}-${profName.split(' ').first.toUpperCase()}';

    final qrData    = 'NotreDamePro\nRef: $refNum\nProf: $profName\nMois: $mois/$annee\nNet: ${paiement['net_a_payer'] ?? paiement['montant_total']} FCFA\nStatut: ${paiement['statut']}\nGénéré: $now';

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: _kPrimary,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Logo + nom école
                pw.Row(children: [
                  pw.Container(
                    width: 64, height: 64,
                    decoration: const pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('COLLÈGE NOTRE DAME',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text('DE TOUTES GRACES',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _kGold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Direction des Ressources Humaines',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColor(1, 1, 1, 0.6))),
                  ]),
                ]),
                // QR + titre
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                  pw.Container(
                    width: 64, height: 64,
                    padding: const pw.EdgeInsets.all(3),
                    decoration: const pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))),
                    child: pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrData, color: PdfColors.black),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(isPaid ? 'FICHE DE PAIE' : 'BON DE CAISSE',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _kGold)),
                ]),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Statut + Référence ───────────────────────────────
          pw.Row(children: [
            _badge(isPaid ? '✓  PAYÉ' : '⏳  EN ATTENTE', isPaid ? _kSuccess : _kGold, PdfColors.white),
            pw.SizedBox(width: 10),
            _badge('Période : $mois / $annee', _kPrimary, PdfColors.white),
            pw.SizedBox(width: 10),
            _badge('Réf : $refNum', PdfColor.fromInt(0xFFE2E8F0), _kTextDark),
          ]),

          pw.SizedBox(height: 16),

          // ── Informations Employé ─────────────────────────────
          _sectionTitle('Informations de l\'Employé'),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _kBg, border: pw.Border.all(color: _kLine),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(children: [
              _empField('Nom & Prénom(s)', profName),
              pw.SizedBox(width: 24),
              _empField('Poste', 'Professeur'),
              pw.SizedBox(width: 24),
              _empField('Mois de paie', '$mois / $annee'),
            ]),
          ),

          pw.SizedBox(height: 20),

          // ── Tableau Rémunération ─────────────────────────────
          _sectionTitle('Détails de Rémunération'),
          pw.SizedBox(height: 8),
          _payTable(paiement),

          pw.SizedBox(height: 20),

          // ── Net à payer ──────────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(colors: [_kSuccess, PdfColor.fromInt(0xFF10B981)]),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('NET À PAYER',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.Text('${paiement['net_a_payer'] ?? paiement['montant_total'] ?? 0} FCFA',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ]),
          ),

          pw.SizedBox(height: 28),

          // ── Signatures ───────────────────────────────────────
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            _signBox('L\'Employé(e)'),
            _signBox('Directeur / Comptabilité'),
          ]),

          pw.Spacer(),

          // ── Footer ───────────────────────────────────────────
          pw.Divider(color: _kLine),
          pw.SizedBox(height: 6),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('NotreDamePro — Document officiel certifié',
                style: const pw.TextStyle(fontSize: 7, color: _kTextGrey)),
            pw.Text('Scannez le QR Code pour vérifier l\'authenticité',
                style: const pw.TextStyle(fontSize: 7, color: _kTextGrey)),
            pw.Text('Généré le $now',
                style: const pw.TextStyle(fontSize: 7, color: _kTextGrey)),
          ]),
        ],
      ),
    ));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Fiche_Paie_${profName}_${mois}_$annee.pdf',
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Row(children: [
      pw.Container(width: 4, height: 18,
          decoration: const pw.BoxDecoration(color: _kPrimary, borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)))),
      pw.SizedBox(width: 8),
      pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _kPrimary)),
    ]);
  }

  static pw.Widget _badge(String text, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: pw.BoxDecoration(color: bg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20))),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: fg)),
    );
  }

  static pw.Widget _empField(String label, String value) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _kTextGrey)),
      pw.SizedBox(height: 3),
      pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _kTextDark)),
    ]);
  }

  static pw.Widget _payTable(Map<String, dynamic> p) {
    pw.Widget headerCell(String t) => pw.Container(
      color: _kPrimary,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(t, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
    pw.Widget rowCell(String t, {bool bold = false, PdfColor? fg, pw.Alignment? align, PdfColor? bg}) =>
        pw.Container(
          color: bg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          alignment: align ?? pw.Alignment.centerLeft,
          child: pw.Text(t, style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: fg ?? _kTextDark)),
        );

    final rows = [
      ['Salaire de base / heure effectuée', '${p['heures_travaillees'] ?? 0} h', '${p['montant_base'] ?? 0} FCFA'],
      ['Primes & Indemnités', '-', '${p['primes'] ?? 0} FCFA'],
      ['Heures supplémentaires', '-', '${p['heures_sup'] ?? 0} FCFA'],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _kLine, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(children: [headerCell('Désignation'), headerCell('Détail'), headerCell('Montant')]),
        ...rows.asMap().entries.map((e) {
          final bg = e.key.isEven ? PdfColors.white : _kBg;
          return pw.TableRow(children: [
            rowCell(e.value[0], bg: bg),
            rowCell(e.value[1], bg: bg, align: pw.Alignment.center),
            rowCell(e.value[2], bg: bg, align: pw.Alignment.centerRight, bold: true),
          ]);
        }),
      ],
    );
  }
}
