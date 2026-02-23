class Moyenne {
  final int eleveId;
  final String eleveNom;
  final String elevePrenom;
  final double? premierInterro;
  final double? deuxiemeInterro;
  final double? troisiemeInterro;
  final double? quatriemeInterro;
  final double? moyenneInterro;
  final double? premierDevoir;
  final double? deuxiemeDevoir;
  final double? moyenneTrimestrielle;
  final int? coefficient;
  final double? moyenneCoefficientee;
  final String? commentaire;
  final int rang;

  Moyenne({
    required this.eleveId,
    required this.eleveNom,
    required this.elevePrenom,
    this.premierInterro,
    this.deuxiemeInterro,
    this.troisiemeInterro,
    this.quatriemeInterro,
    this.moyenneInterro,
    this.premierDevoir,
    this.deuxiemeDevoir,
    this.moyenneTrimestrielle,
    this.coefficient,
    this.moyenneCoefficientee,
    this.commentaire,
    required this.rang,
  });

  factory Moyenne.fromJson(Map<String, dynamic> json) {
    return Moyenne(
      eleveId: json['eleve_id'],
      eleveNom: json['eleve_nom'],
      elevePrenom: json['eleve_prenom'],
      premierInterro: _toDouble(json['premier_interro']),
      deuxiemeInterro: _toDouble(json['deuxieme_interro']),
      troisiemeInterro: _toDouble(json['troisieme_interro']),
      quatriemeInterro: _toDouble(json['quatrieme_interro']),
      moyenneInterro: _toDouble(json['moyenne_interro']),
      premierDevoir: _toDouble(json['premier_devoir']),
      deuxiemeDevoir: _toDouble(json['deuxieme_devoir']),
      moyenneTrimestrielle: _toDouble(json['moyenne_trimestrielle']),
      coefficient: json['coefficient'],
      moyenneCoefficientee: _toDouble(json['moyenne_coefficientee']),
      commentaire: json['commentaire'],
      rang: json['rang'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
