class AppConstants {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';

  // Authentication
  static const String login = '/professeur/login';
  static const String logout = '/professeurs/espace/logout';
  static const String dashboard = '/professeurs/espace/dashboard';

  // Classes & Students
  // Note: /classes/index returns all classes. If you need specific classes for the prof,
  // ensure the backend handles filtering or use the correct endpoint.
  // Note: Updated to use professor-specific endpoint
  static const String classes = '/professeurs/classes';

  // Usage in code: baseUrl + elevesByClasse + '/$id' becomes .../professeurs/presences/eleves/$id
  // This matches Route::get('/presences/eleves/{classe}', ...)
  static const String elevesByClasse = '/professeurs/presences/eleves';

  // Attendance
  static const String presences = '/professeurs/presences';

  // Grades
  static const String notes = '/notes';
  static const String calculerMoyennes =
      '/notes/calculer-moyennes'; // Assuming this exists or will correspond to logic

  // Lesson planner
  static const String cahierTexte = '/cahier-texte';

  // Analytics
  static const String analyseNotes = '/analyse-notes';

  // Profile
  static const String profile =
      '/user'; // Using standard user endpoint for profile info
}
