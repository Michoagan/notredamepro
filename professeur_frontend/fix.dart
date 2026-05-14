import 'dart:io';

void main() {
  final file = File('lib/screens/cahier_texte_screen.dart');
  var lines = file.readAsLinesSync();
  var newLines = <String>[];
  
  for (int i = 0; i < lines.length; i++) {
    // 0-indexed. Lines 578-585 are indices 577-584.
    if (i >= 577 && i <= 584) continue;
    var line = lines[i];
    line = line.replaceAll('..._[', '...[');
    
    // Fix UTF-8 mojibake
    line = line.replaceAll('Ã©', 'é');
    line = line.replaceAll('Ã ', 'à');
    line = line.replaceAll('Ã¨', 'è');
    line = line.replaceAll('â”€â”€', '──');
    line = line.replaceAll('Ãª', 'ê');
    line = line.replaceAll('Ã¢', 'â');
    line = line.replaceAll('Ã®', 'î');
    line = line.replaceAll('Ã´', 'ô');
    line = line.replaceAll('Ã»', 'û');
    line = line.replaceAll('Ã§', 'ç');
    
    newLines.add(line);
  }
  
  file.writeAsStringSync(newLines.join('\n'));
  print('Fixed');
}
