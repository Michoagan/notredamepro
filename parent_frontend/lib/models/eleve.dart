class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final String matricule;
  final String dateNaissance;
  final String classeName;
  final double? tauxPresence;
  final double? soldeRestant;
  final List<dynamic>? recentNotes;

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.dateNaissance,
    required this.classeName,
    this.tauxPresence,
    this.soldeRestant,
    this.recentNotes,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Eleve(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      matricule: json['matricule'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      classeName: json['classe']?['nom'] ?? 'Classe Inconnue',
      tauxPresence: json['taux_presence'] != null
          ? _parseDouble(json['taux_presence'])
          : null,
      soldeRestant: json['solde_restant'] != null
          ? _parseDouble(json['solde_restant'])
          : null,
      recentNotes: json['recent_notes'] as List<dynamic>?,
    );
  }
}
