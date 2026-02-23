class Evenement {
  final int id;
  final String titre;
  final String? description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? lieu;
  final String type;

  Evenement({
    required this.id,
    required this.titre,
    this.description,
    required this.dateDebut,
    required this.dateFin,
    this.lieu,
    required this.type,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'],
      type: json['type'],
    );
  }
}
