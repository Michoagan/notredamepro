import 'dart:html' as html;
import 'dart:convert';
import '../models/moyenne.dart';

class CsvService {
  static Future<void> generateAndDownloadCsv({
    required List<Moyenne> moyennes,
    required String classeName,
    required String matiereName,
    required int trimestre,
  }) async {
    final buffer = StringBuffer();
    // Ajout du BOM pour forcer Excel à lire l'UTF-8 correctement
    buffer.write('\uFEFF');
    buffer.writeln('Rang;Nom;Prénom;Moyenne;Appréciation');

    for (var moyenne in moyennes) {
      final noteText = (moyenne.moyenneTrimestrielle ?? 0.0).toStringAsFixed(2);
      final appreciation =
          _getAppreciation(moyenne.moyenneTrimestrielle ?? 0.0);
      buffer.writeln(
          '${moyenne.rang};${moyenne.eleveNom};${moyenne.elevePrenom};${noteText.replaceAll('.', ',')};$appreciation');
    }

    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'moyennes_${classeName}_T${trimestre}.csv';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static String _getAppreciation(double note) {
    if (note >= 16) return 'Très Bien';
    if (note >= 14) return 'Bien';
    if (note >= 12) return 'Assez Bien';
    if (note >= 10) return 'Passable';
    if (note >= 8) return 'Insuffisant';
    return 'Faible';
  }
}
