import './conseil.dart';
import './chart_dataset.dart';

class NoteAnalysis {
  final List<String> labels;
  final List<ChartDataset> datasets;
  final List<Conseil> conseils;
  final Map<String, dynamic>? notesExamens;

  NoteAnalysis({
    required this.labels,
    required this.datasets,
    required this.conseils,
    this.notesExamens,
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
      notesExamens: (json['notes_examens'] is Map)
          ? Map<String, dynamic>.from(json['notes_examens'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'datasets': datasets.map((e) => e.toJson()).toList(),
      'conseils': conseils.map((e) => e.toJson()).toList(),
      'notes_examens': notesExamens,
    };
  }
}
