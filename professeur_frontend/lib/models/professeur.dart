class Professeur {
  final int id;
  final String lastName;
  final String firstName;
  final String gender;
  final DateTime birthDate;
  final String email;
  final String phone;
  final String matiere;
  final int matiereId;
  final String? photo;
  final String personalCode;
  final bool isActive;
  final String? photoUrl;

  Professeur({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.gender,
    required this.birthDate,
    required this.email,
    required this.phone,
    required this.matiere,
    required this.matiereId,
    this.photo,
    required this.personalCode,
    required this.isActive,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['id'] ?? 0,
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime.now(),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      matiere: json['matiere'] is Map
          ? (json['matiere']['nom'] ?? '')
          : (json['matiere'] ?? ''),
      matiereId: json['matiere_id'] ?? 0,
      photo: json['photo'],
      personalCode: json['personal_code'] ?? '',
      isActive: json['is_active'] ?? true,
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': lastName,
      'first_name': firstName,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
      'email': email,
      'phone': phone,
      'matiere': matiere,
      'matiere_id': matiereId,
      'photo': photo,
      'personal_code': personalCode,
      'is_active': isActive,
      'photo_url': photoUrl,
    };
  }
}
