import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
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
    
    final xFile = XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: 'text/csv',
      name: 'moyennes_${classeName}_T$trimestre.csv',
    );

    await Share.shareXFiles([xFile], text: 'Moyennes $classeName T$trimestre');
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
