import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/premium_app_bar.dart';

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
  bool _isSuccess = false;
  String _message = '';
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCodeController.dispose();
    _newCodeController.dispose();
    _confirmCodeController.dispose();
    super.dispose();
  }

  Future<void> _changeCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _message = ''; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.changeCode(
        _currentCodeController.text.trim(),
        _newCodeController.text.trim(),
      );
      setState(() {
        _isLoading = false;
        _message = result['message'] ?? '';
        _isSuccess = result['success'] == true;
      });
      if (_isSuccess) {
        _currentCodeController.clear();
        _newCodeController.clear();
        _confirmCodeController.clear();
      }
    } catch (e) {
      setState(() { _isLoading = false; _message = 'Erreur: $e'; _isSuccess = false; });
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool show,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !show,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
            onPressed: toggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PremiumAppBar(
        title: 'Sécurité',
        subtitle: 'Modifier le code personnel',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 24),

              // Message feedback
              if (_message.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_isSuccess ? AppTheme.success : AppTheme.error).withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _isSuccess ? AppTheme.success : AppTheme.error, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(_isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                          color: _isSuccess ? AppTheme.success : AppTheme.error, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_message, style: TextStyle(color: _isSuccess ? AppTheme.success : AppTheme.error, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),

              // Form fields
              _buildField(
                controller: _currentCodeController,
                label: 'Code Actuel',
                icon: Icons.lock_outline_rounded,
                show: _showCurrent,
                toggle: () => setState(() => _showCurrent = !_showCurrent),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _newCodeController,
                label: 'Nouveau Code',
                icon: Icons.lock_rounded,
                show: _showNew,
                toggle: () => setState(() => _showNew = !_showNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v.length < 6) return 'Au moins 6 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _confirmCodeController,
                label: 'Confirmer Nouveau Code',
                icon: Icons.lock_clock_rounded,
                show: _showConfirm,
                toggle: () => setState(() => _showConfirm = !_showConfirm),
                validator: (v) => v != _newCodeController.text ? 'Les codes ne correspondent pas' : null,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF2563EB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changeCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
