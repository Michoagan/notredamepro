import 'package:flutter/material.dart';
import '../../models/emploi_du_temps.dart';
import '../../services/api_service.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  const EmploiDuTempsScreen({Key? key}) : super(key: key);

  @override
  _EmploiDuTempsScreenState createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<EmploiDuTemps>> _futureEmploiDuTemps;
  late TabController _tabController;

  final List<String> _jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi'
  ];

  @override
  void initState() {
    super.initState();
    _futureEmploiDuTemps = ApiService().getEmploiDuTemps();

    // Default to current day if weekday, else Monday
    int currentWeekday = DateTime.now().weekday;
    int initialIndex =
        (currentWeekday >= 1 && currentWeekday <= 6) ? currentWeekday - 1 : 0;

    _tabController = TabController(
        length: _jours.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<EmploiDuTemps>> _groupSlotsByDay(List<EmploiDuTemps> slots) {
    Map<String, List<EmploiDuTemps>> grouped = {
      for (var jour in _jours) jour: []
    };
    for (var slot in slots) {
      if (grouped.containsKey(slot.jour)) {
        grouped[slot.jour]!.add(slot);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Emploi du Temps'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _jours.map((jour) => Tab(text: jour)).toList(),
        ),
      ),
      body: FutureBuilder<List<EmploiDuTemps>>(
        future: _futureEmploiDuTemps,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureEmploiDuTemps = ApiService().getEmploiDuTemps();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Aucun cours programmé.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final slots = snapshot.data!;
          final groupedSlots = _groupSlotsByDay(slots);

          return TabBarView(
            controller: _tabController,
            children: _jours.map((jour) {
              final jourSlots = groupedSlots[jour]!;
              if (jourSlots.isEmpty) {
                return const Center(
                  child: Text(
                    'Journée libre',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jourSlots.length,
                itemBuilder: (context, index) {
                  final slot = jourSlots[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  slot.heureDebut.substring(0, 5),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                const Text('-',
                                    style: TextStyle(color: Colors.grey)),
                                Text(
                                  slot.heureFin.substring(0, 5),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.classe?['nom'] ?? 'Classe inconnue',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.menu_book,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        slot.matiere?['nom'] ??
                                            'Matière inconnue',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                                if (slot.salle != null &&
                                    slot.salle!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.room,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Salle: ${slot.salle}',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
