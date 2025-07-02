import 'package:flutter/material.dart';
import 'widgets/recent_visit_card.dart';

class RecentHistoryScreen extends StatelessWidget {
  final List<dynamic> recentVisits;
  const RecentHistoryScreen({Key? key, required this.recentVisits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Medical History'),
      ),
      body: recentVisits.isEmpty
          ? const Center(child: Text('No recent history found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recentVisits.length,
              itemBuilder: (context, index) {
                return RecentVisitCard(
                  visit: recentVisits[index],
                );
              },
            ),
    );
  }
} 