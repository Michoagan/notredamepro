class DashboardStats {
  final int classesCount;
  final int elevesCount;
  final int coursSemaine;

  DashboardStats({
    required this.classesCount,
    required this.elevesCount,
    required this.coursSemaine,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      classesCount: json['classes_count'] ?? 0,
      elevesCount: json['eleves_count'] ?? 0,
      coursSemaine: json['cours_semaine'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes_count': classesCount,
      'eleves_count': elevesCount,
      'cours_semaine': coursSemaine,
    };
  }
}