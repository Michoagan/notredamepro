import 'professeur.dart';
import 'matiere.dart';

class Classe {
  final int id;
  final String nom;
  final String niveau;
  final int? professeurPrincipalId;
  final double coutContribution;
  final int capaciteMax;
  final bool isActive;
  final int elevesCount;
  final Professeur? professeurPrincipal;
  final List<Matiere>? matieres;

  Classe({
    required this.id,
    required this.nom,
    required this.niveau,
    this.professeurPrincipalId,
    this.coutContribution = 0.0,
    this.capaciteMax = 0,
    this.isActive = true,
    this.elevesCount = 0,
    this.professeurPrincipal,
    this.matieres,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      niveau: json['niveau'] ?? '',
      professeurPrincipalId: json['professeur_principal_id'],
      coutContribution: _parseDouble(json['cout_contribution']) ?? 0.0,
      capaciteMax: json['capacite_max'] ?? 0,
      isActive: json['is_active'] ?? true,
      elevesCount: json['eleves_count'] ?? 0,
      professeurPrincipal: json['professeur_principal'] != null
          ? Professeur.fromJson(json['professeur_principal'])
          : null,
      matieres: json['matieres'] != null
          ? List<Matiere>.from(json['matieres'].map((x) => Matiere.fromJson(x)))
          : null,
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
      'niveau': niveau,
      'professeur_principal_id': professeurPrincipalId,
      'cout_contribution': coutContribution,
      'capacite_max': capaciteMax,
      'is_active': isActive,
      'eleves_count': elevesCount,
      'professeur_principal': professeurPrincipal?.toJson(),
      'matieres': matieres?.map((x) => x.toJson()).toList(),
    };
  }

  String get displayName => '$nom - $niveau';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
