import 'package:flutter/material.dart';
import 'package:minecraft_server_automation/common/interfaces/auth_service.dart';

/// Auth form component that accepts an AuthService interface
/// This makes it easy to inject mock services for testing
class AuthForm extends StatefulWidget {
  final AuthService authService;
  final VoidCallback? onAuthSuccess;
  final bool showDebugOptions;

  const AuthForm({
    super.key,
    required this.authService,
    this.onAuthSuccess,
    this.showDebugOptions = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;

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
    widget.authService.clearError();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    widget.authService.clearError();

    if (_isSignUp) {
      await widget.authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await widget.authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (mounted && widget.authService.isSignedIn) {
      widget.onAuthSuccess?.call();
    }
  }

  Future<void> _debugLogin() async {
    if (!mounted) return;

    _emailController.text = 'debug@example.com';
    _passwordController.text = 'password123';

    widget.authService.clearError();
    await widget.authService.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && widget.authService.isSignedIn) {
      widget.onAuthSuccess?.call();
    }
  }

  Future<void> _debugCreateAccount() async {
    if (!mounted) return;

    _emailController.text = 'debug@example.com';
    _passwordController.text = 'password123';

    widget.authService.clearError();
    await widget.authService.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && widget.authService.isSignedIn) {
      widget.onAuthSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            enabled: !widget.authService.isLoading,
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            enabled: !widget.authService.isLoading,
          ),
          const SizedBox(height: 24),

          // Error message
          if (widget.authService.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.authService.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          ElevatedButton(
            onPressed: widget.authService.isLoading ? null : _handleAuth,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.authService.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Please wait...'),
                    ],
                  )
                : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
          ),
          const SizedBox(height: 16),

          // Toggle auth mode
          TextButton(
            onPressed: widget.authService.isLoading ? null : _toggleAuthMode,
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : 'Don\'t have an account? Sign Up',
            ),
          ),

          // Debug buttons (only if enabled)
          if (widget.showDebugOptions) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Debug Options',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: widget.authService.isLoading ? null : _debugLogin,
              child: const Text('Debug Login'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed:
                  widget.authService.isLoading ? null : _debugCreateAccount,
              child: const Text('Debug Create Account'),
            ),
          ],
        ],
      ),
    );
  }
}
