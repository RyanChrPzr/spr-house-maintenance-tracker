import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../auth_notifier.dart';
import '../auth_provider.dart';

/// Login screen — shown at `/auth/login` for returning users.
///
/// Submits credentials via [AuthNotifier.signIn]. On success, fetches the
/// user's profile to determine their role and navigates to the appropriate
/// dashboard. Incorrect credentials show an inline error.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? emailErr;
    String? passwordErr;

    if (email.isEmpty || !email.contains('@')) {
      emailErr = 'Enter a valid email address.';
    }
    if (password.isEmpty) {
      passwordErr = 'Password is required.';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
    return emailErr == null && passwordErr == null;
  }

  void _onLoginPressed() {
    if (!_validateForm()) return;
    ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _navigateToRoleDashboard() async {
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null || !mounted) return;
    try {
      final profile = await ref.read(authRepositoryProvider).getProfile(user.id);
      if (!mounted) return;
      if (profile.userType == 'homeowner') {
        context.go('/homeowner');
      } else {
        context.go('/vendor');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load profile: $e'),
          backgroundColor: AppConstants.statusError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        final err = next.error;
        if (err is AppException && err.code == 'invalid-credentials') {
          setState(() => _loginError = err.message);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: AppConstants.statusError,
            ),
          );
        }
      }
      if (next.hasValue && previous?.isLoading == true) {
        setState(() => _loginError = null);
        _navigateToRoleDashboard();
      }
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppConstants.backgroundApp,
      appBar: AppBar(
        title: const Text('Log In'),
        backgroundColor: AppConstants.backgroundApp,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            TextField(
              key: const Key('email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password *',
                errorText: _passwordError,
              ),
            ),
            if (_loginError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _loginError!,
                  key: const Key('login_error_text'),
                  style: const TextStyle(color: AppConstants.statusError, fontSize: 12),
                ),
              ),
            const Spacer(),
            FilledButton(
              key: const Key('login_button'),
              onPressed: isLoading ? null : _onLoginPressed,
              child: isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Log In'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/auth/register'),
              child: const Text("Don't have an account? Register"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
