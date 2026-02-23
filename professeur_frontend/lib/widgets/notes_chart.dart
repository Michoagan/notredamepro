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

    return LineChart(
      LineChartData(
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
                  // Only show label if it fits, simple logic: show all for now
                  // For many labels, we might need to skip some
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
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: 20,
        lineBarsData: datasets.map((dataset) {
          return LineChartBarData(
            spots: dataset.data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
            isCurved: true,
            color: _parseColor(dataset.borderColor),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _parseColor(dataset.borderColor).withOpacity(0.1),
            ),
          );
        }).toList(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final datasetIndex = barSpot.barIndex;
                final dataset = datasets[datasetIndex];

                return LineTooltipItem(
                  '${dataset.label}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: flSpot.y.toString(),
                      style: TextStyle(
                        color: _parseColor(dataset.borderColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
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
