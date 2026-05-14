class Conseil {
  final String type;
  final List<String> recommandations;

  Conseil({required this.type, required this.recommandations});

  factory Conseil.fromJson(Map<String, dynamic> json) {
    return Conseil(
      type: json['type'],
      recommandations: List<String>.from(json['recommandations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'recommandations': recommandations};
  }
}
