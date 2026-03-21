import 'classe.dart';
import 'professeur.dart';

class CahierTexte {
  final int id;
  final int classeId;
  final int professeurId;
  final DateTime dateCours;
  final int dureeCours;
  final String heureDebut;
  final String notionCours;
  final Classe? classe;
  final String travailAFaire;
  final bool isNonFait;
  final List<int> elevesNonFaitsIds;
  final Professeur? professeur;

  CahierTexte({
    required this.id,
    required this.classeId,
    required this.professeurId,
    required this.dateCours,
    required this.dureeCours,
    required this.heureDebut,
    required this.notionCours,
    this.travailAFaire = '',
    this.isNonFait = false,
    this.elevesNonFaitsIds = const [],
    this.classe,
    this.professeur,
  });

  factory CahierTexte.fromJson(Map<String, dynamic> json) {
    return CahierTexte(
      id: json['id'] ?? 0,
      classeId: json['classe_id'] ?? 0,
      professeurId: json['professeur_id'] ?? 0,
      dateCours: json['date_cours'] != null 
          ? DateTime.parse(json['date_cours']) 
          : DateTime.now(),
      dureeCours: json['duree_cours'] ?? 1,
      heureDebut: json['heure_debut'] ?? '',
      notionCours: json['notion_cours'] ?? '',
      travailAFaire: json['travail_a_faire'] ?? '',
      isNonFait: json['is_non_fait'] ?? false,
      elevesNonFaitsIds: json['eleves_non_faits'] != null
          ? (json['eleves_non_faits'] as List).map<int>((e) => e['id'] as int).toList()
          : [],
      classe: json['classe'] != null ? Classe.fromJson(json['classe']) : null,
      professeur: json['professeur'] != null ? Professeur.fromJson(json['professeur']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classe_id': classeId,
      'professeur_id': professeurId,
      'date_cours': dateCours.toIso8601String(),
      'duree_cours': dureeCours,
      'heure_debut': heureDebut,
      'notion_cours': notionCours,
      'classe': classe?.toJson(),
      'professeur': professeur?.toJson(),
    };
  }
}