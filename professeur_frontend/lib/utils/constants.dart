class AppConstants {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class ApiConstants {
  // URL de production
  static const String baseUrl = 'https://schoolndtg.onrender.com/api';

  // Authentication
  static const String login = '/professeur/login';
  static const String logout = '/professeurs/espace/logout';
  static const String dashboard = '/professeurs/espace/dashboard';

  // Classes & Students
  static const String classes = '/professeurs/classes';
  static const String elevesByClasse = '/professeurs/presences/eleves';

  // Attendance
  static const String presences = '/professeurs/presences';

  // Grades
  static const String notes = '/notes';
  static const String calculerMoyennes = '/notes/calculer-moyennes';

  // Lesson planner
  static const String cahierTexte = '/cahier-texte';

  // Analytics
  static const String analyseNotes = '/analyse-notes';

  // Emploi du temps
  static const String emploiDuTemps = '/professeurs/espace/emploi-du-temps';

  // Salaires / Paiements
  static const String mesPaiements = '/professeur/mes-paiements';
  static const String accusePaiement = '/professeurs/espace/mes-salaires';

  // Profile
  static const String profile = '/user';
}
