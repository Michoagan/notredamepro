import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/chart_dataset.dart';
import '../utils/theme.dart';

class NotesChart extends StatelessWidget {
  final List<String> labels;
  final List<ChartDataset> datasets;

  const NotesChart({super.key, required this.labels, required this.datasets});

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty || labels.isEmpty) {
      return const Center(child: Text("Pas de données à afficher"));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = labels[group.x];
              final dataset = datasets[rodIndex];
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${dataset.label}: ${rod.toY.round()}',
                    style: TextStyle(
                      color: _parseColor(dataset.borderColor),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatLabel(labels[index]),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d).withOpacity(0.1)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: labels.asMap().entries.map((entry) {
          final index = entry.key;
          return BarChartGroupData(
            x: index,
            barRods: datasets.asMap().entries.map((datasetEntry) {
              final dataset = datasetEntry.value;
              // Ensure we don't access out of bounds if dataset has fewer points
              final yValue =
                  index < dataset.data.length ? dataset.data[index] : 0.0;
              return BarChartRodData(
                toY: yValue,
                color: _parseColor(dataset.borderColor),
                width: datasets.length > 2
                    ? 8
                    : 16, // Adjust width based on number of datasets
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  String _formatLabel(String label) {
    if (label.length > 10) {
      return '${label.substring(0, 10)}...';
    }
    return label;
  }

  Color _parseColor(String colorString) {
    try {
      colorString = colorString.trim();
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xff')));
      } else if (colorString.startsWith('rgba')) {
        final parts = colorString
            .substring(colorString.indexOf('(') + 1, colorString.indexOf(')'))
            .split(',')
            .map((e) => e.trim())
            .toList();
        if (parts.length >= 3) {
          final r = int.parse(parts[0]);
          final g = int.parse(parts[1]);
          final b = int.parse(parts[2]);
          final a = parts.length > 3 ? double.tryParse(parts[3]) ?? 1.0 : 1.0;
          return Color.fromRGBO(r, g, b, a);
        }
      } else if (colorString.startsWith('rgb')) {
        final parts = colorString
            .substring(colorString.indexOf('(') + 1, colorString.indexOf(')'))
            .split(',')
            .map((e) => e.trim())
            .toList();
        if (parts.length >= 3) {
          return Color.fromARGB(
            255,
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
      return AppTheme.primary;
    } catch (e) {
      return AppTheme.primary;
    }
  }
}
