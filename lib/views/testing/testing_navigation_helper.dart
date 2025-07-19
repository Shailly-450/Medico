import 'package:flutter/material.dart';
import 'testing_home_screen.dart';

class TestingNavigationHelper {
  // Add testing option to any menu or drawer
  static Widget buildTestingMenuItem(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.science,
        color: Colors.blue,
      ),
      title: const Text('Testing Suite'),
      subtitle: const Text('Backend API Testing'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestingHomeScreen(),
          ),
        );
      },
    );
  }

  // Add testing button to any screen
  static Widget buildTestingButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestingHomeScreen(),
          ),
        );
      },
      icon: const Icon(Icons.science),
      label: const Text('Testing'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // Add testing option to app bar actions
  static List<Widget> buildTestingActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.science),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TestingHomeScreen(),
            ),
          );
        },
        tooltip: 'Testing Suite',
      ),
    ];
  }

  // Show testing option in a bottom sheet
  static void showTestingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Testing Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.api, color: Colors.green),
              title: const Text('Backend API Testing'),
              subtitle: const Text('Test all backend endpoints'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestingHomeScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
} 