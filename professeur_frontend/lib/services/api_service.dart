import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/professeur.dart';
import '../models/dashboard_stats.dart';
import '../models/classe.dart';
import '../models/moyenne.dart';
import '../models/eleve.dart';
import '../models/presence.dart';
import '../models/matiere.dart';
import '../models/cahier_texte.dart';
import '../models/note_analysis.dart';
import '../models/communique.dart';
import '../models/evenement.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    return _token;
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _buildUrl(String endpoint, {Map<String, dynamic>? params}) {
    String url = '${ApiConstants.baseUrl}$endpoint';

    if (params != null && params.isNotEmpty) {
      url += '?';
      params.forEach((key, value) {
        if (value != null) {
          url += '$key=$value&';
        }
      });
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  Future<Map<String, dynamic>> login(String email, String personalCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'personal_code': personalCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Store token
          final token = data['access_token'];
          await saveToken(token);

          // Store user info if needed
          final user = data['user'];
          // You might want to store user details in shared preferences or a state manager
          return {
            'success': true,
            'professeur': user, // Assuming 'user' key contains professeur data
            'token': token
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur de connexion'
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Email ou code personnel incorrect'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  Future<bool> logout() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await removeToken();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboard}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final professeurData = data['professeur'];
          final statsData = data['stats'];
          // The backend returns classes inside the professeur object primarily,
          // but let's check if it's sent separately or within professeur.
          // Based on ProfesseurController::dashboard, it returns 'professeur' (with loaded classes) and 'stats'.

          final professeur = Professeur.fromJson(professeurData);

          // Extract classes from the professeur data if available,
          // essentially re-parsing part of the JSON or relying on what's in 'professeurData'
          List<Classe> classes = [];
          if (professeurData['classes'] != null) {
            classes = List<Classe>.from(
                professeurData['classes'].map((x) => Classe.fromJson(x)));
          }

          // Extract communiques
          List<Communique> communiques = [];
          if (data['communiques'] != null) {
            communiques = List<Communique>.from(
                data['communiques'].map((x) => Communique.fromJson(x)));
          }

          // Extract evenements
          List<Evenement> evenements = [];
          if (data['evenements'] != null) {
            evenements = List<Evenement>.from(
                data['evenements'].map((x) => Evenement.fromJson(x)));
          }

          return {
            'success': true,
            'professeur': professeur,
            'stats': DashboardStats.fromJson(statsData),
            'classes': classes,
            'communiques': communiques,
            'evenements': evenements,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur de chargement',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              'Erreur de chargement des données (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  Future<List<Classe>> getClasses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classes}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Classe>.from(
              data['classes'].map((x) => Classe.fromJson(x)));
        } else {
          throw Exception(
              data['message'] ?? 'Erreur de chargement des classes');
        }
      } else {
        throw Exception(
            'Erreur de chargement des classes (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<Eleve>> getElevesByClasse(int classeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.elevesByClasse}/$classeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Eleve>.from(data['eleves'].map((x) => Eleve.fromJson(x)));
        } else {
          throw Exception(data['message'] ?? 'Erreur de chargement des élèves');
        }
      } else {
        throw Exception(
            'Erreur de chargement des élèves (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<Presence>> getPresencesByClasse(int classeId, String date) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.presences}/$classeId?date=$date'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final presencesData = data['presences'];
          if (presencesData is Map) {
            return presencesData.values
                .map((presenceData) => Presence.fromJson(presenceData))
                .toList();
          } else if (presencesData is List) {
            return [];
          } else {
            return [];
          }
        } else {
          throw Exception(
              data['message'] ?? 'Erreur de chargement des présences');
        }
      } else {
        throw Exception(
            'Erreur de chargement des présences (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> storePresences({
    required int classeId,
    required String date,
    required int cours,
    required List<int> absents,
    String? remarquesGenerales,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.presences}'),
        headers: headers,
        body: json.encode({
          'classe_id': classeId,
          'date': date,
          'cours': cours,
          'absents': absents,
          'remarques_generales': remarquesGenerales ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Présences enregistrées avec succès',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur lors de l\'enregistrement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<List<Matiere>> getMatieresByClasse(int classeId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/professeurs/classes/$classeId/matieres'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Matiere>.from(
              data['matieres'].map((x) => Matiere.fromJson(x)));
        } else {
          throw Exception(
              data['message'] ?? 'Erreur de chargement des matières');
        }
      } else {
        throw Exception(
            'Erreur de chargement des matières (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> getNotes({
    required int classeId,
    required int trimestre,
    required int matiereId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = _buildUrl(ApiConstants.notes, params: {
        'classe_id': classeId.toString(),
        'trimestre': trimestre.toString(),
        'matiere_id': matiereId.toString(),
      });

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'eleves':
                List<Eleve>.from(data['eleves'].map((x) => Eleve.fromJson(x))),
            'notes': data['notes_existantes'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erreur de chargement des notes',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Erreur de chargement des notes (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> storeNotes({
    required int classeId,
    required int trimestre,
    required int matiereId,
    required String typeNote,
    required int numero,
    required Map<String, dynamic> notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.notes}'),
        headers: headers,
        body: json.encode({
          'classe_id': classeId,
          'trimestre': trimestre,
          'matiere_id': matiereId,
          'type_note': typeNote,
          'numero': numero,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Notes enregistrées avec succès',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur lors de l\'enregistrement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<List<Moyenne>> calculerMoyennes({
    required int classeId,
    required int trimestre,
    required int matiereId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.calculerMoyennes}'),
        headers: headers,
        body: json.encode({
          'classe_id': classeId,
          'trimestre': trimestre,
          'matiere_id': matiereId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Moyenne>.from(
              data['moyennesAvecRang'].map((x) => Moyenne.fromJson(x)));
        } else {
          throw Exception(
              data['message'] ?? 'Erreur lors du calcul des moyennes');
        }
      } else {
        throw Exception(
            'Erreur lors du calcul des moyennes (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<CahierTexte>> getCahierTexte() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cahierTexte}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<CahierTexte>.from(
              data['cahiers'].map((x) => CahierTexte.fromJson(x)));
        } else {
          throw Exception(
              data['message'] ?? 'Erreur de chargement du cahier de texte');
        }
      } else {
        throw Exception(
            'Erreur de chargement du cahier de texte (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> storeCahierTexte({
    required int classeId,
    required int matiereId,
    required String dateCours,
    required int dureeCours,
    required String heureDebut,
    required String notionCours,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cahierTexte}'),
        headers: headers,
        body: json.encode({
          'classe_id': classeId,
          'matiere_id': matiereId,
          'date_cours': dateCours,
          'duree_cours': dureeCours,
          'heure_debut': heureDebut,
          'notion_cours': notionCours,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message':
              data['message'] ?? 'Cahier de texte enregistré avec succès',
          'cahier': data['cahier'] != null
              ? CahierTexte.fromJson(data['cahier'])
              : null,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur lors de l\'enregistrement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCahierTexte(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cahierTexte}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Entrée supprimée avec succès',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur lors de la suppression',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<NoteAnalysis?> getNoteAnalysis({
    required int classeId,
    int? eleveId,
    int? matiereId,
    int? trimestreFilter,
    String type = 'all',
  }) async {
    try {
      final url = _buildUrl(ApiConstants.analyseNotes, params: {
        'type': type,
        'classe_id': classeId.toString(),
        'eleve_id': eleveId?.toString(),
        'matiere_id': matiereId?.toString(),
        'trimestre': trimestreFilter?.toString(),
      });

      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (data['analyse_data'] != null) {
            return NoteAnalysis.fromJson(data['analyse_data']);
          }
          return null; // Return null if no analysis data
        } else {
          throw Exception(
              data['message'] ?? 'Erreur de chargement de l\'analyse');
        }
      } else {
        throw Exception(
            'Erreur de chargement de l\'analyse (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'professeur': data, // Assuming /user returns the user object directly
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur de chargement du profil (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (lastName != null) body['last_name'] = lastName;
      if (firstName != null) body['first_name'] = firstName;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (currentPassword != null) body['current_password'] = currentPassword;
      if (newPassword != null) body['new_password'] = newPassword;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Profil mis à jour avec succès',
          'professeur': data['professeur'] != null
              ? Professeur.fromJson(data['professeur'])
              : null,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erreur lors de la mise à jour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // --- Gestion du Code Personnel ---

  Future<Map<String, dynamic>> changeCode(
      String currentCode, String newCode) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/professeur/change-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_code': currentCode,
          'new_code': newCode,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors du changement de code'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/professeur/forgot-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la demande'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }

  Future<Map<String, dynamic>> resetCode(
      String email, String code, String newPersonalCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/professeur/reset-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'code': code,
          'new_personal_code': newPersonalCode,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de la réinitialisation'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: $e'};
    }
  }
}
