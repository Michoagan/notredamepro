import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ForgotCodeScreen extends StatefulWidget {
  const ForgotCodeScreen({super.key});

  @override
  _ForgotCodeScreenState createState() => _ForgotCodeScreenState();
}

class _ForgotCodeScreenState extends State<ForgotCodeScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newCodeController = TextEditingController();

  int _step = 1; // 1: Email, 2: Reset Code
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  void _sendResetCode() async {
    if (_emailController.text.isEmpty) {
      setState(() => _message = 'Veuillez entrer votre email');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.forgotCode(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        _message = result['message'];
        _isSuccess = result['success'];
      });

      if (result['success']) {
        setState(() => _step = 2);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Erreur: $e';
      });
    }
  }

  void _resetCode() async {
    if (_codeController.text.isEmpty || _newCodeController.text.isEmpty) {
      setState(() => _message = 'Veuillez remplir tous les champs');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.resetCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _newCodeController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _message = result['message'];
        _isSuccess = result['success'];
      });

      if (result['success']) {
        // Delay and go back to login
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Erreur: $e';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récupération de Code'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _isSuccess ? Colors.green[800] : Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_step == 1) ...[
                const Text(
                  'Entrez votre email pour recevoir un code de réinitialisation.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppTheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Envoyer le code',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
              if (_step == 2) ...[
                const Text(
                  'Entrez le code reçu par email et votre nouveau mot de passe.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Code de réinitialisation',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newCodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau Code Personnel',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppTheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Réinitialiser le code',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
