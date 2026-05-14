import 'classe.dart';

class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String lieuNaissance;
  final String genre;
  final String adresse;
  final String telephone;
  final String email;
  final String? photo;
  final int classeId;
  final String? nomTuteur;
  final String? telephoneTuteur;
  final DateTime dateInscription;
  final bool isActive;
  final String? photoUrl;
  final Classe? classe;

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.genre,
    required this.adresse,
    required this.telephone,
    required this.email,
    this.photo,
    required this.classeId,
    this.nomTuteur,
    this.telephoneTuteur,
    required this.dateInscription,
    required this.isActive,
    this.photoUrl,
    this.classe,
  });

  String get fullName => '$prenom $nom';

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      dateNaissance: json['date_naissance'] != null
          ? DateTime.parse(json['date_naissance'])
          : DateTime.now(),
      lieuNaissance: json['lieu_naissance'] ?? '',
      genre: json['genre'] ?? '',
      adresse: json['adresse'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'],
      classeId: json['classe_id'] ?? 0,
      nomTuteur: json['nom_parent'] ?? json['nom_tuteur'],
      telephoneTuteur: json['telephone_parent'] ?? json['telephone_tuteur'],
      dateInscription: json['date_inscription'] != null
          ? DateTime.parse(json['date_inscription'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
      photoUrl: json['photo_url'],
      classe: json['classe'] != null ? Classe.fromJson(json['classe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance.toIso8601String(),
      'lieu_naissance': lieuNaissance,
      'genre': genre,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'photo': photo,
      'classe_id': classeId,
      'nom_tuteur': nomTuteur,
      'telephone_tuteur': telephoneTuteur,
      'date_inscription': dateInscription.toIso8601String(),
      'is_active': isActive,
      'photo_url': photoUrl,
      'classe': classe?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Eleve && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
