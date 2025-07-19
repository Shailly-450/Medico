import 'package:flutter/material.dart';
import 'testing_navigation_helper.dart';

// Example of how to integrate testing into your existing app
class IntegrationExample extends StatelessWidget {
  const IntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medico App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Option 1: Add testing to app bar actions
        actions: TestingNavigationHelper.buildTestingActions(context),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Medico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Your existing menu items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to home
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Appointments'),
              onTap: () {
                // Navigate to appointments
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                // Navigate to chat
              },
            ),
            // Option 2: Add testing to drawer menu
            TestingNavigationHelper.buildTestingMenuItem(context),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Medico',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your health companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      // Option 3: Add testing as floating action button
      floatingActionButton: TestingNavigationHelper.buildTestingButton(context),
    );
  }
}

// Example of adding testing to an existing screen
class ExistingScreenExample extends StatelessWidget {
  const ExistingScreenExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Existing Screen'),
        actions: [
          // Add testing option to existing actions
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Your existing settings action
            },
          ),
          // Add testing option
          ...TestingNavigationHelper.buildTestingActions(context),
        ],
      ),
      body: const Center(
        child: Text('Your existing screen content'),
      ),
      // Option 4: Show testing in bottom sheet
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TestingNavigationHelper.showTestingOptions(context);
        },
        child: const Icon(Icons.science),
      ),
    );
  }
}

// Example of conditional testing (only in debug mode)
class DebugTestingExample extends StatelessWidget {
  const DebugTestingExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Testing Example'),
        actions: [
          // Only show testing in debug mode
          if (const bool.fromEnvironment('dart.vm.product') == false)
            ...TestingNavigationHelper.buildTestingActions(context),
        ],
      ),
      body: const Center(
        child: Text('This screen shows testing only in debug mode'),
      ),
    );
  }
} 