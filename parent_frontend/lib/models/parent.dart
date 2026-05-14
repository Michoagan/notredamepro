class Parent {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;

  Parent({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
    );
  }
}
