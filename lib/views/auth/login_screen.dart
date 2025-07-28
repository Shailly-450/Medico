import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../admin/appointments/admin_appointments_panel.dart';
import 'package:medico/views/home/home_screen.dart';
import 'package:medico/views/doctor/patients/patient_list_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';
import 'forgot_password_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'package:medico/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medico/core/services/api_service.dart';
import 'package:medico/core/services/onesignal_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    // Initialize auth service
    AuthService.initialize();
    _checkBiometricAvailability();
  }

  final _secureStorage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // UserId secure storage
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: 'user_id', value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }

  Future<void> clearUserId() async {
    await _secureStorage.delete(key: 'user_id');
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  Future<bool> authenticateWithBiometrics() async {
    final auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;
      return await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e);
      return false;
    }
  }

void _checkBiometricAvailability() async {
  final enabled = await isBiometricEnabled();
  final token = await getToken();
  final userId = await getUserId();
  print('Biometric enabled: $enabled, token: $token, userId: $userId');
  setState(() {
    _biometricAvailable = enabled && token != null && userId != null;
  });
}

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter both email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting login with email: $email, password: $password');
      final result = await AuthService.login(email, password);
      print('Login result: $result');
      if (result['success'] == true) {
        final token = result['token'];
        final userId = result['user']?['id'] ?? result['data']?['user']?['id'];
        final refreshToken = result['refreshToken'] ?? result['data']?['refreshToken'] ?? 'dummy-refresh-token';
        if (token == null || userId == null) {
          print('Raw login response: $result');
          _showSnackBar('Login failed: No token or userId received');
          return;
        }
        // Sync ApiService token
        await ApiService.saveTokens(token, refreshToken);
        // Check biometric preference
        final prefs = await SharedPreferences.getInstance();
        final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
        if (biometricEnabled) {
          await saveToken(token);
          await saveUserId(userId);
          _checkBiometricAvailability();
        } else {
          await clearToken();
          await clearUserId();
          _checkBiometricAvailability();
        }
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setToken(token);
        print('Raw login response: $result');
        
        // Register user with OneSignal for push notifications
        await OneSignalService.instance.registerUser(
          userId: userId,
          email: email,
          name: result['user']?['profile']?['name'] ?? result['data']?['user']?['profile']?['name'],
        );
        
        _showSnackBar('Login successful!');
        // Navigate based on user role
        final role = result['role'] ?? result['user']?['role'] ?? result['data']?['user']?['role'];
        if (mounted) {
          if (role == UserRole.admin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (role == UserRole.doctor) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorDashboardScreen(),
              ),
            );
          } else {
            // Patient or default
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        _showSnackBar(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnackBar('Login error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleBiometricLogin() async {
    setState(() { _isLoading = true; });
    try {
      final enabled = await isBiometricEnabled();
      final token = await getToken();
      final userId = await getUserId();
      if (!enabled || token == null || userId == null) {
        _showSnackBar('Biometric login not available. Please login with email and password first.');
        setState(() { _isLoading = false; });
        _checkBiometricAvailability();
        return;
      }
      final authenticated = await authenticateWithBiometrics();
      if (!authenticated) {
        _showSnackBar('Biometric authentication failed.');
        setState(() { _isLoading = false; });
        _checkBiometricAvailability();
        return;
      }
      // Send token and userId to your API
      final result = await AuthService.loginWithTokenAndUserId(token, userId);
      if (result['success'] == true) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final newToken = result['data']?['token'];
        final refreshToken = result['data']?['refreshToken'] ?? 'dummy-refresh-token';
        if (newToken != null) {
          authProvider.setToken(newToken);
          await saveToken(newToken);
          await ApiService.saveTokens(newToken, refreshToken);
        }
        _showSnackBar('Login successful!');
        final role = result['data']?['user']?['role'];
        if (mounted) {
          if (role == UserRole.admin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (role == UserRole.doctor) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorDashboardScreen(),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        _showSnackBar('Session expired. Please login with email and password.');
        await clearToken();
        await clearUserId();
        _checkBiometricAvailability();
      }
    } catch (e) {
      _showSnackBar('Biometric login error: ${e.toString()}');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('successful') ? Colors.green : Colors.red,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Hello there ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                    Text(
                      ', please login to continue.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Email',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'e.g. test@medico.com',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Password',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                if (_biometricAvailable) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleBiometricLogin,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login with Biometrics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Test credentials hint
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Test Credentials',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: test@medico.com\nPassword: test123',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Don't have an account yet? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
