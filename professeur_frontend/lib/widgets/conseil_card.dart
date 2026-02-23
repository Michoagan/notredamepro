import 'package:flutter/material.dart';
import '../models/conseil.dart';
import '../utils/theme.dart';

class ConseilCard extends StatelessWidget {
  final Conseil conseil;

  const ConseilCard({super.key, required this.conseil});

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;
    IconData iconData;

    // Determine colors and icon based on type
    if (conseil.type.contains('Interro')) {
      primaryColor = const Color(0xFFFFA726); // Orange
      secondaryColor = const Color(0xFFFFCC80);
      iconData = Icons.assignment_late_outlined;
    } else if (conseil.type.contains('Devoir')) {
      primaryColor = AppTheme.success; // Green
      secondaryColor = const Color(0xFFA5D6A7);
      iconData = Icons.assignment_turned_in_outlined;
    } else if (conseil.type.contains('Trimestre')) {
      primaryColor = AppTheme.secondary; // Blue/Purple
      secondaryColor = const Color(0xFF90CAF9);
      iconData = Icons.insights_outlined;
    } else {
      primaryColor = AppTheme.error; // Red
      secondaryColor = const Color(0xFFEF9A9A);
      iconData = Icons.warning_amber_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Watermark Icon
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                iconData,
                size: 100,
                color: primaryColor.withOpacity(0.05),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal Header Strip
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                Icon(iconData, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              conseil.type,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Recommendations List
                      ...conseil.recommandations
                          .map((rec) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: primaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        rec,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
