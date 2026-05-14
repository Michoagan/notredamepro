class Communique {
  final int id;
  final String titre;
  final String contenu;
  final String type;
  final DateTime publishedAt;

  Communique({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    required this.publishedAt,
  });

  factory Communique.fromJson(Map<String, dynamic> json) {
    return Communique(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      type: json['type'],
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}
