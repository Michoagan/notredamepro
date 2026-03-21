import 'package:flutter/material.dart';
import '../models/professeur.dart';
import '../utils/theme.dart';

class ModernDashboardHeader extends StatelessWidget {
  final Professeur professeur;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onMenuPressed;

  const ModernDashboardHeader({
    super.key,
    required this.professeur,
    this.onSettingsPressed,
    this.onNotificationPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240, // Slightly taller for more breathing room
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Softer shadow
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding:
          const EdgeInsets.fromLTRB(24, 56, 24, 28), // Adjusted for safe area
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: onMenuPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  // Avatar Image (School Logo or Saint)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const Text(
                'ND Toutes Grâces',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 26),
                    onPressed: onNotificationPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(), // Use spacer for flexible layouts
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${professeur.firstName} ${professeur.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    professeur.firstName.isNotEmpty
                        ? professeur.firstName[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
