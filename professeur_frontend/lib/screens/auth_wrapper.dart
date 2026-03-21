import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiService().getToken();

    if (token != null) {
      final LocalAuthentication auth = LocalAuthentication();
      try {
        final bool canAuthenticateWithBiometrics =
            await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (canAuthenticate) {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason:
                'Veuillez vous authentifier pour accéder à votre espace professeur',
            biometricOnly: false,
          );

          if (didAuthenticate) {
            _navigateTo(const DashboardScreen());
            return;
          }
        } else {
          _navigateTo(const DashboardScreen());
          return;
        }
      } catch (e) {
        // Fallback to login silently
      }
    }

    // Fallback: Failed or not authenticated
    _navigateTo(const LoginScreen());
  }

  void _navigateTo(Widget screen) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.green[700]),
      ),
    );
  }
}
