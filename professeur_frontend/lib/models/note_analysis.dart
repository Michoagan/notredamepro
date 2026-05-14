import './conseil.dart';
import './chart_dataset.dart';

class NoteAnalysis {
  final List<String> labels;
  final List<ChartDataset> datasets;
  final List<Conseil> conseils;
  final Map<String, dynamic>? notesExamens;
  final Map<String, dynamic>? statistiques; // ← données enrichies backend

  NoteAnalysis({
    required this.labels,
    required this.datasets,
    required this.conseils,
    this.notesExamens,
    this.statistiques,
  });

  factory NoteAnalysis.fromJson(Map<String, dynamic> json) {
    return NoteAnalysis(
      labels: List<String>.from(json['labels'] ?? []),
      datasets: List<ChartDataset>.from(
        (json['datasets'] ?? []).map((x) => ChartDataset.fromJson(x)),
      ),
      conseils: List<Conseil>.from(
        (json['conseils'] ?? []).map((x) => Conseil.fromJson(x)),
      ),
      notesExamens: (json['notes_examens'] is Map)
          ? Map<String, dynamic>.from(json['notes_examens'] as Map)
          : null,
      statistiques: (json['statistiques'] is Map)
          ? Map<String, dynamic>.from(json['statistiques'] as Map)
          : null,
    );
  }

  // Helpers pour accès facile aux stats
  double get moyenneGenerale =>
      (statistiques?['moyenne_generale'] as num?)?.toDouble() ?? 0.0;
  int get rang => (statistiques?['rang'] as num?)?.toInt() ?? 0;
  int get effectifClasse =>
      (statistiques?['effectif_classe'] as num?)?.toInt() ?? 0;
  int get tauxReussite =>
      (statistiques?['taux_reussite'] as num?)?.toInt() ?? 0;
  double get ecartVsClasse =>
      (statistiques?['ecart_vs_classe'] as num?)?.toDouble() ?? 0.0;
  String get tendance => statistiques?['tendance'] ?? 'stable';
  double get meilleureNote =>
      (statistiques?['meilleure_note'] as num?)?.toDouble() ?? 0.0;
  double get pireNote =>
      (statistiques?['pire_note'] as num?)?.toDouble() ?? 0.0;

  List<Map<String, dynamic>> get parTrimestre {
    final raw = statistiques?['par_trimestre'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return [];
  }

  Map<String, dynamic> get distribution {
    final raw = statistiques?['distribution'];
    if (raw is Map) return raw.cast<String, dynamic>();
    return {};
  }

  bool get isIndividual => statistiques?.containsKey('nom_eleve') ?? false;

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'datasets': datasets.map((e) => e.toJson()).toList(),
      'conseils': conseils.map((e) => e.toJson()).toList(),
      'notes_examens': notesExamens,
      'statistiques': statistiques,
    };
  }
}
