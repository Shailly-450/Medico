import 'package:flutter/material.dart';
import 'package:medico/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/registration/registration_screen.dart';
import 'views/schedule/schedule_screen.dart';
import 'views/search/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medico',
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (context) => const OnboardingScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/home': (context) => const MainNavigationShell(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DummyDashboardScreen(),
    const ScheduleScreen(),
    const DummyProfileScreen(),
  ];

  void _onItemTapped(int index) {
    print('Bottom nav tapped: $index');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.theme.colorScheme.secondary.withOpacity(0.2),
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DummyDashboardScreen extends StatelessWidget {
  const DummyDashboardScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard Screen (Coming Soon)'));
  }
}

class DummyProfileScreen extends StatelessWidget {
  const DummyProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen (Coming Soon)'));
  }
}
