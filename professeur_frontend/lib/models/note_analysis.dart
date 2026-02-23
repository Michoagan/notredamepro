import './conseil.dart';
import './chart_dataset.dart';

class NoteAnalysis {
  final List<String> labels;
  final List<ChartDataset> datasets;
  final List<Conseil> conseils;

  NoteAnalysis({
    required this.labels,
    required this.datasets,
    required this.conseils,
  });

  factory NoteAnalysis.fromJson(Map<String, dynamic> json) {
    return NoteAnalysis(
      labels: List<String>.from(json['labels']),
      datasets: List<ChartDataset>.from(
        json['datasets'].map((x) => ChartDataset.fromJson(x)),
      ),
      conseils: List<Conseil>.from(
        json['conseils'].map((x) => Conseil.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'datasets': datasets.map((e) => e.toJson()).toList(),
      'conseils': conseils.map((e) => e.toJson()).toList(),
    };
  }
}
