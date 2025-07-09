import 'package:flutter/material.dart';
import 'package:medico/views/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'core/services/navigation_service.dart';
import 'core/services/order_service.dart';
import 'core/theme/app_theme.dart';
import 'models/hospital.dart';
import 'views/auth/login_screen.dart';
import 'views/registration/registration_screen.dart';
import 'views/schedule/schedule_screen.dart';
import 'views/search/search_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/welcome_screen.dart';
import 'views/category/category_screen.dart';
import 'views/appointments/appointment_calendar_screen.dart';
import 'views/orders/orders_screen.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/order_view_model.dart';
import 'views/profile/profile_screen.dart';
import 'viewmodels/family_members_view_model.dart';
import 'views/prescriptions/prescriptions_screen.dart';
import 'views/prescriptions/test_prescriptions_screen.dart';
import 'views/workflow/medical_workflow_screen.dart';
import 'views/workflow/workflow_demo_screen.dart';
import 'views/ai_symptom/ai_symptom_chat_screen.dart';
import 'views/admin/appointments/admin_appointments_panel.dart';
import 'views/admin/appointments/admin_appointment_detail_screen.dart';
import 'core/services/ai_symptom_service.dart';

void main() {
  // Initialize mock data for OrderService
  OrderService.initializeMockData();
  // Initialize AI Symptom Service
  AISymptomService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(create: (_) => NavigationService()),
        ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
        ChangeNotifierProvider<OrderViewModel>(create: (_) => OrderViewModel()),
        ChangeNotifierProvider<FamilyMembersViewModel>(
            create: (_) => FamilyMembersViewModel()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Medico',
          theme: AppTheme.theme,
          navigatorKey: Provider.of<NavigationService>(context, listen: false)
              .navigatorKey,
          initialRoute: '/welcome',
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/registration': (context) => const RegistrationScreen(),
            '/home': (context) => const MainNavigationShell(),
            '/dashboard': (context) => const DashboardScreen(),
            '/schedule': (context) => const ScheduleScreen(),
            '/search': (context) => const SearchScreen(),
            '/category': (context) => const CategoryScreen(),
            '/appointment-calendar': (context) =>
                const AppointmentCalendarScreen(),
            '/orders': (context) => const OrdersScreen(),
            '/prescriptions': (context) => const PrescriptionsScreen(),
            '/test-prescriptions': (context) => const TestPrescriptionsScreen(),
            '/workflow': (context) => const MedicalWorkflowScreen(),
            '/workflow-demo': (context) => const WorkflowDemoScreen(),
            '/ai-symptom-chat': (context) => const AISymptomChatScreen(),
            '/admin/appointments': (context) => const AdminAppointmentsPanel(),
          },
          onGenerateRoute: (settings) {
            print('Navigating to: ${settings.name}');

            if (settings.name == '/category') {
              final String? categoryName = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) =>
                    CategoryScreen(categoryName: categoryName),
              );
            }

            // if (settings.name == '/hospital-detail') {
            //   final hospital = settings.arguments as Hospital;
            //   return MaterialPageRoute(
            //     builder: (context) => HospitalDetailScreen( name: '', address: '',),
            //   );
            // }

            return null;
          },
        ),
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
  final List<int> _tabHistory = [0];

  final List<Widget> _screens = [
    const HomeScreen(),
    const DashboardScreen(),
    const ScheduleScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      _tabHistory.add(index);
    });
  }

  Future<bool> _onWillPop() async {
    if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        _selectedIndex = _tabHistory.last;
      });
      return false; // Don't exit the app
    }
    return true; // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DummyProfileScreen extends StatelessWidget {
  const DummyProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen (Coming Soon)'));
  }
}
