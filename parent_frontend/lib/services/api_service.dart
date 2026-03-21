import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import '../models/emploi_du_temps.dart';

class ApiService extends ChangeNotifier {
  // Ajustez l'URL selon votre vrai backend
  static const String baseUrl = 'http://localhost:8000/api';
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('parent_token');
    notifyListeners();
  }

  // Login générique, connecté au controller côté Laravel
  Future<Map<String, dynamic>> login(
    String credentials,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': credentials, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token =
            data['access_token']; // Note: in TuteurController it returns 'access_token'

        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('parent_token', _token!);
          notifyListeners();
          return {'success': true, 'message': 'Connexion réussie'};
        } else {
          return {
            'success': false,
            'message': 'Jeton de connexion manquant dans la réponse.',
          };
        }
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Erreur lors de la connexion.',
      };
    } catch (e) {
      debugPrint('Erreur login: $e');
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur.',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Enregistrement réussi, sauvegarde du token
        _token = responseData['access_token'];
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('parent_token', _token!);
          notifyListeners();
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Inscription réussie',
        };
      } else {
        // Erreur (ex: email déjà pris, ou parent non trouvé)
        debugPrint('Register Error: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      debugPrint('Erreur register: $e');
      return {'success': false, 'message': 'Erreur de connexion au serveur.'};
    }
  }

  Future<Map<String, dynamic>?> getDashboardData() async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/dashboard'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getDashboardData: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNotes(int eleveId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/notes/$eleveId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getNotes: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPaiements(int eleveId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/paiements?eleve_id=$eleveId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getPaiements: $e');
      return null;
    }
  }

  // --- Reçus de Paiement ---
  Future<Uint8List?> getReceiptPdf(int paiementId) async {
    try {
      if (_token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/parent/paiements/$paiementId/receipt'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint(
          'Erreur getReceiptPdf (${response.statusCode}): ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception getReceiptPdf: $e');
      return null;
    }
  }

  Future<bool> sendMessage(String sujet, String message) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/contact'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'sujet': sujet, 'message': message}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erreur sendMessage: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPresences(int eleveId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/presences/$eleveId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getPresences: $e');
      return null;
    }
  }

  Future<List<EmploiDuTemps>?> getEmploiDuTemps(int eleveId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/emploi-du-temps/$eleveId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<EmploiDuTemps>.from(
            data['emplois_du_temps'].map((x) => EmploiDuTemps.fromJson(x)),
          );
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getEmploiDuTemps: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getConvocations(int eleveId) async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/convocations/$eleveId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getConvocations: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAlertesScolarite() async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/alertes-scolarite'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getAlertesScolarite: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Erreur forgotPassword: $e');
      return {'success': false, 'message': 'Erreur de connexion.'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': newPassword,
          'password_confirmation': newPassword,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Erreur resetPassword: $e');
      return {'success': false, 'message': 'Erreur de connexion.'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_token == null)
      return {'success': false, 'message': 'Non authentifié.'};
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/change-password'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Erreur changePassword: $e');
      return {'success': false, 'message': 'Erreur de connexion.'};
    }
  }

  Future<Map<String, dynamic>?> processPayment(
    double amount,
    String paymentMethod,
    int eleveId,
    double montantTotal,
  ) async {
    if (_token == null) return null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/process-payment'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: {
          'amount': amount.toString(),
          'payment_method': paymentMethod,
          'eleve_id': eleveId.toString(),
          'montant_total': montantTotal.toString(),
        },
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Erreur processPayment: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNotifications() async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parent/notifications'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getNotifications: $e');
      return null;
    }
  }

  Future<bool> markNotificationAsRead(String id) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parent/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur markNotificationAsRead: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parent_token');
    notifyListeners();
  }
}
