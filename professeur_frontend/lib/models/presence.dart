class Presence {
  final int id;
  final int eleveId;
  final int classeId;
  final DateTime date;
  final int cours;
  final bool present;
  final int professeurId;
  final String? remarque;

  Presence({
    required this.id,
    required this.eleveId,
    required this.classeId,
    required this.date,
    required this.cours,
    required this.present,
    required this.professeurId,
    this.remarque,
  });

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json['id'] ?? 0,
      eleveId: json['eleve_id'] ?? 0,
      classeId: json['classe_id'] ?? 0,
      date: DateTime.parse(json['date']),
      cours: json['cours'] ?? 0,
      present: json['present'] ?? false,
      professeurId: json['professeur_id'] ?? 0,
      remarque: json['remarque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eleve_id': eleveId,
      'classe_id': classeId,
      'date': date.toIso8601String(),
      'cours': cours,
      'present': present,
      'professeur_id': professeurId,
      'remarque': remarque,
    };
  }
}
