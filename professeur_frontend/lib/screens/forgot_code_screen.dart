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

  int _step = 1;
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  bool _showNewCode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _message = 'Veuillez entrer votre email');
      return;
    }
    setState(() { _isLoading = true; _message = ''; });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final result = await api.forgotCode(_emailController.text.trim());
      setState(() { _isLoading = false; _message = result['message'] ?? ''; _isSuccess = result['success'] == true; });
      if (_isSuccess) setState(() => _step = 2);
    } catch (e) {
      setState(() { _isLoading = false; _message = 'Erreur: $e'; _isSuccess = false; });
    }
  }

  Future<void> _resetCode() async {
    if (_codeController.text.trim().isEmpty || _newCodeController.text.trim().isEmpty) {
      setState(() => _message = 'Veuillez remplir tous les champs');
      return;
    }
    setState(() { _isLoading = true; _message = ''; });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final result = await api.resetCode(
        _emailController.text.trim(), _codeController.text.trim(), _newCodeController.text.trim(),
      );
      setState(() { _isLoading = false; _message = result['message'] ?? ''; _isSuccess = result['success'] == true; });
      if (_isSuccess) {
        Future.delayed(const Duration(seconds: 2), () { if (mounted) Navigator.pop(context); });
      }
    } catch (e) {
      setState(() { _isLoading = false; _message = 'Erreur: $e'; _isSuccess = false; });
    }
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          suffixIcon: toggle != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: AppTheme.textSecondary),
                  onPressed: toggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String label, required IconData icon, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF2563EB)],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Premium hero header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF040E3E), Color(0xFF1A237E), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.key_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _step == 1 ? 'Code Oublié ?' : 'Réinitialisation',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 1
                          ? 'Entrez votre email pour recevoir un code de réinitialisation.'
                          : 'Entrez le code reçu par email et votre nouveau code.',
                      style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
                    ),
                    // Step indicator
                    const SizedBox(height: 20),
                    Row(children: [
                      _buildStepDot(1, _step >= 1),
                      Expanded(child: Container(height: 2, color: _step >= 2 ? Colors.white : Colors.white.withAlpha(60))),
                      _buildStepDot(2, _step >= 2),
                    ]),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Feedback message
                    if (_message.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (_isSuccess ? AppTheme.success : AppTheme.error).withAlpha(15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _isSuccess ? AppTheme.success : AppTheme.error, width: 1.5),
                        ),
                        child: Row(children: [
                          Icon(_isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                              color: _isSuccess ? AppTheme.success : AppTheme.error),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_message, style: TextStyle(
                              color: _isSuccess ? AppTheme.success : AppTheme.error, fontWeight: FontWeight.w600))),
                        ]),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (_step == 1) ...[
                      _buildInput(
                        controller: _emailController,
                        label: 'Adresse Email',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 28),
                      _buildGradientButton(
                        label: 'Envoyer le Code',
                        icon: Icons.send_rounded,
                        onPressed: _isLoading ? null : _sendResetCode,
                      ),
                    ],

                    if (_step == 2) ...[
                      _buildInput(
                        controller: _codeController,
                        label: 'Code de Réinitialisation',
                        icon: Icons.pin_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        controller: _newCodeController,
                        label: 'Nouveau Code Personnel',
                        icon: Icons.lock_rounded,
                        obscure: !_showNewCode,
                        toggle: () => setState(() => _showNewCode = !_showNewCode),
                      ),
                      const SizedBox(height: 28),
                      _buildGradientButton(
                        label: 'Réinitialiser',
                        icon: Icons.check_circle_rounded,
                        onPressed: _isLoading ? null : _resetCode,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() { _step = 1; _message = ''; }),
                        child: const Text('← Retour à l\'étape 1', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int step, bool active) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withAlpha(40),
        shape: BoxShape.circle,
        boxShadow: active ? [BoxShadow(color: Colors.white.withAlpha(60), blurRadius: 8)] : null,
      ),
      child: Center(
        child: Text('$step', style: TextStyle(
          color: active ? AppTheme.primary : Colors.white60,
          fontWeight: FontWeight.w900, fontSize: 14,
        )),
      ),
    );
  }
}
