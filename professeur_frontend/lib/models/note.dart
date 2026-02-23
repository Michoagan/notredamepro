class Note {
  final int id;
  final double? premierInterro;
  final double? deuxiemeInterro;
  final double? troisiemeInterro;
  final double? quatriemeInterro;
  final double? moyenneInterro;
  final double? premierDevoir;
  final double? deuxiemeDevoir;
  final double? moyenneTrimestrielle;
  final double coefficient;
  final double? moyenneCoefficientee;
  final int trimestre;
  final String? commentaire;
  final int eleveId;
  final int classeId;
  final int professeurId;
  final int matiereId;

  Note({
    required this.id,
    this.premierInterro,
    this.deuxiemeInterro,
    this.troisiemeInterro,
    this.quatriemeInterro,
    this.moyenneInterro,
    this.premierDevoir,
    this.deuxiemeDevoir,
    this.moyenneTrimestrielle,
    required this.coefficient,
    this.moyenneCoefficientee,
    required this.trimestre,
    this.commentaire,
    required this.eleveId,
    required this.classeId,
    required this.professeurId,
    required this.matiereId,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      premierInterro: _parseDouble(json['premier_interro']),
      deuxiemeInterro: _parseDouble(json['deuxieme_interro']),
      troisiemeInterro: _parseDouble(json['troisieme_interro']),
      quatriemeInterro: _parseDouble(json['quatrieme_interro']),
      moyenneInterro: _parseDouble(json['moyenne_interro']),
      premierDevoir: _parseDouble(json['premier_devoir']),
      deuxiemeDevoir: _parseDouble(json['deuxieme_devoir']),
      moyenneTrimestrielle: _parseDouble(json['moyenne_trimestrielle']),
      coefficient: _parseDouble(json['coefficient']) ?? 1.0,
      moyenneCoefficientee: _parseDouble(json['moyenne_coefficientee']),
      trimestre: json['trimestre'] ?? 1,
      commentaire: json['commentaire'],
      eleveId: json['eleve_id'] ?? 0,
      classeId: json['classe_id'] ?? 0,
      professeurId: json['professeur_id'] ?? 0,
      matiereId: json['matiere_id'] ?? 0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'premier_interro': premierInterro,
      'deuxieme_interro': deuxiemeInterro,
      'troisieme_interro': troisiemeInterro,
      'quatrieme_interro': quatriemeInterro,
      'moyenne_interro': moyenneInterro,
      'premier_devoir': premierDevoir,
      'deuxieme_devoir': deuxiemeDevoir,
      'moyenne_trimestrielle': moyenneTrimestrielle,
      'coefficient': coefficient,
      'moyenne_coefficientee': moyenneCoefficientee,
      'trimestre': trimestre,
      'commentaire': commentaire,
      'eleve_id': eleveId,
      'classe_id': classeId,
      'professeur_id': professeurId,
      'matiere_id': matiereId,
    };
  }
}
