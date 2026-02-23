import 'package:flutter/material.dart';
import '../models/evenement.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Evenement event;
  final bool isFeatured;

  const EventCard({super.key, required this.event, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFeatured ? 280 : double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date Box
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        AppTheme.primary.withOpacity(0.08), // Softer background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(event.dateDebut),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(event.dateDebut).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6), // Slightly wider gap
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Align icons/text
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(event.dateDebut),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (event.lieu != null && event.lieu!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_rounded,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.lieu!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
