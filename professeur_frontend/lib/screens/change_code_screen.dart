import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ChangeCodeScreen extends StatefulWidget {
  const ChangeCodeScreen({super.key});

  @override
  _ChangeCodeScreenState createState() => _ChangeCodeScreenState();
}

class _ChangeCodeScreenState extends State<ChangeCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCodeController = TextEditingController();
  final _newCodeController = TextEditingController();
  final _confirmCodeController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  void _changeCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final result = await apiService.changeCode(
          _currentCodeController.text.trim(),
          _newCodeController.text.trim(),
        );

        setState(() {
          _isLoading = false;
          _message = result['message'];
          _isSuccess = result['success'];
        });

        if (result['success']) {
          _currentCodeController.clear();
          _newCodeController.clear();
          _confirmCodeController.clear();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _message = 'Erreur: $e';
          _isSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier Code Personnel'),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        // Android Optimization
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: AppTheme.primary),
                const SizedBox(height: 24),
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[800] : Colors.red[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _currentCodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Code Actuel',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Veuillez entrer le code actuel' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newCodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau code';
                    }
                    if (value.length < 6) {
                      return 'Le code doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCodeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer Nouveau Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value != _newCodeController.text) {
                      return 'Les codes ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _changeCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer le nouveau code',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
