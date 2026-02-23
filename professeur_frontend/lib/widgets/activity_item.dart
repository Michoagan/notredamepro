// widgets/activity_item.dart
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle; // Ajoutez cette ligne
  final String time;

  const ActivityItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle, // Ajoutez cette ligne
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) // Ajoutez cette condition
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
