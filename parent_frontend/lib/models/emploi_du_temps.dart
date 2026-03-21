class EmploiDuTemps {
  final int id;
  final int classeId;
  final int matiereId;
  final int professeurId;
  final String jour;
  final String heureDebut;
  final String heureFin;
  final String? salle;
  final Map<String, dynamic>? classe;
  final Map<String, dynamic>? matiere;
  final Map<String, dynamic>? professeur;

  EmploiDuTemps({
    required this.id,
    required this.classeId,
    required this.matiereId,
    required this.professeurId,
    required this.jour,
    required this.heureDebut,
    required this.heureFin,
    this.salle,
    this.classe,
    this.matiere,
    this.professeur,
  });

  factory EmploiDuTemps.fromJson(Map<String, dynamic> json) {
    return EmploiDuTemps(
      id: json['id'],
      classeId: json['classe_id'],
      matiereId: json['matiere_id'],
      professeurId: json['professeur_id'],
      jour: json['jour'],
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      salle: json['salle'],
      classe: json['classe'],
      matiere: json['matiere'],
      professeur: json['professeur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classe_id': classeId,
      'matiere_id': matiereId,
      'professeur_id': professeurId,
      'jour': jour,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'salle': salle,
      'classe': classe,
      'matiere': matiere,
      'professeur': professeur,
    };
  }
}
