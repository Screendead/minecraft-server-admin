import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minecraft_server_automation/providers/auth_provider.dart';
import 'package:minecraft_server_automation/common/widgets/forms/auth_form.dart';
import 'package:minecraft_server_automation/common/di/service_locator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    if (_isSignUp) {
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _debugLogin() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isSignUp = false; // Ensure we're in login mode
    });

    // Fill in debug credentials
    _emailController.text = 'debug@example.com';
    _passwordController.text = 'password123';

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _debugCreateAccount() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isSignUp = true; // Ensure we're in signup mode
    });

    // Fill in debug credentials
    _emailController.text = 'debug@example.com';
    _passwordController.text = 'password123';

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo/Icon
                      const Icon(
                        Icons.sports_esports,
                        size: 64,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        _isSignUp
                            ? 'Join Minecraft Server Admin'
                            : 'Welcome back to Minecraft Server Admin',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Auth Form
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          // Get the auth service from the service locator
                          final serviceLocator = ServiceLocator();
                          final authService = serviceLocator.authService;

                          return AuthForm(
                            authService: authService,
                            showDebugOptions: kDebugMode,
                            onAuthSuccess: () {
                              // Auth success is handled by the provider
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
