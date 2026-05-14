import 'package:flutter/material.dart';
import '../models/moyenne.dart';
import '../utils/theme.dart';

class MoyenneTable extends StatelessWidget {
  final List<Moyenne> moyennes;

  const MoyenneTable({super.key, required this.moyennes});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        // Largeur minimale pour éviter d'écraser les colonnes
        constraints: const BoxConstraints(minWidth: 780),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF243570)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF122251)),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) return const Color(0xFF1C2D5E);
                return const Color(0xFF152047);
              }),
              dataRowMinHeight: 44,
              dataRowMaxHeight: 48,
              columnSpacing: 12,
              horizontalMargin: 10,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD700),
                fontSize: 11,
              ),
              dataTextStyle: const TextStyle(
                color: Color(0xFFF1F5FF),
                fontSize: 12,
              ),
              columns: const [
                DataColumn(label: Text('Rg')),
                DataColumn(label: Text('Nom & Prénom')),
                DataColumn(label: Text('I1'), numeric: true),
                DataColumn(label: Text('I2'), numeric: true),
                DataColumn(label: Text('I3'), numeric: true),
                DataColumn(label: Text('I4'), numeric: true),
                DataColumn(label: Text('M.I',
                    style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w900))),
                DataColumn(label: Text('D1'), numeric: true),
                DataColumn(label: Text('D2'), numeric: true),
                DataColumn(label: Text('Moy',
                    style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w900))),
                DataColumn(label: Text('Cf'), numeric: true),
                DataColumn(label: Text('M.C',
                    style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w900))),
                DataColumn(label: Text('Appr.')),
              ],
              rows: moyennes.map((m) {
                final isPodium = m.rang <= 3;
                final moy = m.moyenneTrimestrielle;
                return DataRow(cells: [
                  // Rang
                  DataCell(Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isPodium ? AppTheme.gold.withOpacity(0.2) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(
                      '${m.rang}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: isPodium ? AppTheme.gold : AppTheme.textSecondary,
                      ),
                    )),
                  )),
                  // Nom
                  DataCell(Text(
                    '${m.eleveNom.toUpperCase()} ${m.elevePrenom}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  )),
                  // Notes interrogations
                  DataCell(_noteText(m.premierInterro)),
                  DataCell(_noteText(m.deuxiemeInterro)),
                  DataCell(_noteText(m.troisiemeInterro)),
                  DataCell(_noteText(m.quatriemeInterro)),
                  // Moy Interro
                  DataCell(_noteText(m.moyenneInterro, bold: true, color: AppTheme.secondary)),
                  // Devoirs
                  DataCell(_noteText(m.premierDevoir)),
                  DataCell(_noteText(m.deuxiemeDevoir)),
                  // Moy Trimestrielle
                  DataCell(_moyBadge(moy)),
                  // Coeff
                  DataCell(Text('${m.coefficient ?? '-'}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11))),
                  // Moy Coefficientée
                  DataCell(_noteText(m.moyenneCoefficientee, bold: true, color: AppTheme.primaryDark)),
                  // Appréciation
                  DataCell(_apprBadge(moy)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteText(double? v, {bool bold = false, Color? color}) {
    if (v == null) return const Text('-', style: TextStyle(color: Color(0xFF6678AA), fontSize: 11));
    final isPass = v >= 10;
    return Text(
      v.toStringAsFixed(1),
      style: TextStyle(
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        color: color ?? (isPass ? AppTheme.success : AppTheme.error),
        fontSize: 12,
      ),
    );
  }

  Widget _moyBadge(double? moy) {
    if (moy == null) return const Text('-', style: TextStyle(color: Colors.grey, fontSize: 11));
    final isPass = moy >= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isPass ? AppTheme.success.withOpacity(0.12) : AppTheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        moy.toStringAsFixed(2),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: isPass ? AppTheme.success : AppTheme.error,
        ),
      ),
    );
  }

  Widget _apprBadge(double? moy) {
    if (moy == null) return const Text('-', style: TextStyle(fontSize: 11, color: Colors.grey));
    String label;
    Color bg;
    Color fg = Colors.white;
    if (moy >= 16) { label = 'T. Bien'; bg = const Color(0xFF059669); }
    else if (moy >= 14) { label = 'Bien'; bg = const Color(0xFF0891B2); }
    else if (moy >= 12) { label = 'A. Bien'; bg = const Color(0xFF7C3AED); }
    else if (moy >= 10) { label = 'Passable'; bg = const Color(0xFFF59E0B); fg = Colors.black87; }
    else if (moy >= 8)  { label = 'Insuffis.'; bg = const Color(0xFFEA580C); }
    else { label = 'Faible'; bg = const Color(0xFFDC2626); }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
