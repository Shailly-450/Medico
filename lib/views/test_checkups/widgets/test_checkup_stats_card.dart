import 'package:flutter/material.dart';

class TestCheckupStatsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  const TestCheckupStatsCard({Key? key, required this.statistics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Total', statistics['total'] ?? 0,
                Icons.medical_services, Colors.blue),
            _buildStat(
                'Today', statistics['today'] ?? 0, Icons.today, Colors.indigo),
            _buildStat('Upcoming', statistics['upcoming'] ?? 0, Icons.upcoming,
                Colors.green),
            _buildStat('Overdue', statistics['overdue'] ?? 0, Icons.warning,
                Colors.red),
            _buildStat('Completed', statistics['completed'] ?? 0,
                Icons.check_circle, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text('$value',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
