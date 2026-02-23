import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ApiService())],
      child: const NdtgParentApp(),
    ),
  );
}

class NdtgParentApp extends StatelessWidget {
  const NdtgParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDTG Parent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home:
          const LoginScreen(), // Sera remplacÃ© plus tard par une vÃ©rification de l'auth
    );
  }
}
