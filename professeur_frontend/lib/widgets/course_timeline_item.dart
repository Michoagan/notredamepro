import 'package:flutter/material.dart';
import '../models/classe.dart';
import '../utils/theme.dart';

class CourseTimelineItem extends StatelessWidget {
  final Classe classe;
  final String startTime;
  final String endTime;
  final String subject;
  final bool isNext; // Highlights the next upcoming course

  const CourseTimelineItem({
    super.key,
    required this.classe,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                startTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                endTime,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isNext ? AppTheme.secondary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: isNext
                      ? Border.all(
                          color: AppTheme.secondary.withOpacity(0.3), width: 4)
                      : null,
                ),
              ),
              Container(
                width: 2,
                height: 80, // Adjust based on card height
                color: Colors.grey.shade200,
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Course Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
                gradient: isNext
                    ? LinearGradient(
                        colors: [
                          Colors.white,
                          AppTheme.primary.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: isNext
                    ? Border.all(color: AppTheme.primary.withOpacity(0.1))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isNext
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_outlined,
                      color: isNext ? AppTheme.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classe.displayName,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isNext)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
