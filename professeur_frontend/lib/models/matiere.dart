class Matiere {
  final int id;
  final String nom;
  final double? coefficient;
  final int? ordreAffichage;

  Matiere({
    required this.id,
    required this.nom,
    this.coefficient,
    this.ordreAffichage,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      coefficient: _parseDouble(json['coefficient']),
      ordreAffichage: json['ordre_affichage'],
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
      'nom': nom,
      'coefficient': coefficient,
      'ordre_affichage': ordreAffichage,
    };
  }

  String get displayName {
    if (coefficient != null) {
      return '$nom (Coef: $coefficient)';
    }
    return nom;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Matiere && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
