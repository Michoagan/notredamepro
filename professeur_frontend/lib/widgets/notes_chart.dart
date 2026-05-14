import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/chart_dataset.dart';
import '../utils/theme.dart';

class NotesChart extends StatefulWidget {
  final List<String> labels;
  final List<ChartDataset> datasets;

  const NotesChart({super.key, required this.labels, required this.datasets});

  @override
  State<NotesChart> createState() => _NotesChartState();
}

class _NotesChartState extends State<NotesChart> {
  int? _touchedSpot;

  @override
  Widget build(BuildContext context) {
    if (widget.datasets.isEmpty || widget.labels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 48, color: AppTheme.textMuted.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('Aucune donnée disponible',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (widget.datasets.length > 1) ...[
          _buildLegend(),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: LineChart(
            _buildChartData(),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      minY: 0,
      maxY: 20,

      // ── Tooltip ────────────────────────────────────────────────
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          setState(() {
            if (response?.lineBarSpots != null &&
                response!.lineBarSpots!.isNotEmpty) {
              _touchedSpot = response.lineBarSpots!.first.spotIndex;
            } else {
              _touchedSpot = null;
            }
          });
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.surfaceLight,
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          getTooltipItems: (List<LineBarSpot> spots) {
            return spots.map((spot) {
              final ds = widget.datasets[spot.barIndex];
              final color = _datasetColor(spot.barIndex, ds.borderColor);
              final isPass = spot.y >= 10;
              return LineTooltipItem(
                '${widget.labels[spot.x.toInt()]}  ',
                const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: spot.y.toStringAsFixed(2),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: '/20  ',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  TextSpan(
                    text: isPass ? '✓' : '✗',
                    style: TextStyle(
                      color: isPass ? AppTheme.success : AppTheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),

      // ── Grille ─────────────────────────────────────────────────
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) => FlLine(
          color: value == 10
              ? AppTheme.gold.withOpacity(0.35)
              : AppTheme.surfaceBorder.withOpacity(0.4),
          strokeWidth: value == 10 ? 1.5 : 0.8,
          dashArray: value == 10 ? null : [4, 6],
        ),
      ),

      borderData: FlBorderData(show: false),

      // ── Axes ───────────────────────────────────────────────────
      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatLabel(widget.labels[index]),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            reservedSize: 34,
            getTitlesWidget: (value, meta) {
              final isKey =
                  value == 10.0 || value == 0.0 || value == 20.0;
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: value == 10
                      ? AppTheme.gold.withOpacity(0.9)
                      : AppTheme.textMuted,
                  fontSize: isKey ? 11 : 10,
                  fontWeight:
                      isKey ? FontWeight.w700 : FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),

      // ── Lignes de données ───────────────────────────────────────
      lineBarsData: widget.datasets.asMap().entries.map((entry) {
        final index = entry.key;
        final ds = entry.value;
        final color = _datasetColor(index, ds.borderColor);

        final spots = ds.data.asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), e.value.clamp(0.0, 20.0));
        }).toList();

        return LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.22),
                color.withOpacity(0.0),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, i) {
              final isTouched = _touchedSpot == i;
              return FlDotCirclePainter(
                radius: isTouched ? 6 : 4,
                color: isTouched ? color : AppTheme.surface,
                strokeWidth: 2,
                strokeColor: color,
              );
            },
          ),
        );
      }).toList(),

      // ── Ligne de passage à 10/20 ────────────────────────────────
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 10,
            color: AppTheme.gold.withOpacity(0.55),
            strokeWidth: 1.5,
            dashArray: [8, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              style: TextStyle(
                color: AppTheme.gold.withOpacity(0.85),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
              labelResolver: (_) => 'Passage',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.datasets.asMap().entries.map((entry) {
        final color = _datasetColor(entry.key, entry.value.borderColor);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              entry.value.label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _datasetColor(int index, String colorStr) {
    const palette = [
      Color(0xFF38BDF8),
      Color(0xFF10B981),
      Color(0xFFFFD700),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
    ];
    final parsed = _parseColor(colorStr);
    if (parsed != AppTheme.primary) return parsed;
    return palette[index % palette.length];
  }

  String _formatLabel(String label) {
    return label.length > 9 ? '${label.substring(0, 8)}..' : label;
  }

  Color _parseColor(String colorString) {
    try {
      colorString = colorString.trim();
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xff')));
      }
      return AppTheme.primary;
    } catch (_) {
      return AppTheme.primary;
    }
  }
}
