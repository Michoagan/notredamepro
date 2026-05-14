import 'package:flutter/material.dart';

class ExportButton extends StatelessWidget {
  final VoidCallback onExport;

  const ExportButton({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.download_rounded),
      onPressed: onExport,
      tooltip: 'Exporter',
      color: Colors.white,
    );
  }
}
