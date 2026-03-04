import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../auth_notifier.dart';

/// Registration screen — the app's initial route (`/auth/register`).
///
/// Collects email + password, validates client-side on submit, then calls
/// [AuthNotifier.register]. On success navigates to `/auth/role-selection`.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

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
    if (password.length < 6) {
      passwordErr = 'Password must be at least 6 characters.';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passwordErr;
    });
    return emailErr == null && passwordErr == null;
  }

  void _onRegisterPressed() {
    if (!_validateForm()) return;
    ref.read(authNotifierProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      if (next.hasError) {
        final err = next.error;
        if (err is AppException && err.code == 'user-already-exists') {
          setState(() => _emailError = err.message);
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
        context.go('/auth/role-selection');
      }
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppConstants.backgroundApp,
      appBar: AppBar(
        title: const Text('Create Account'),
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password *',
                errorText: _passwordError,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: isLoading ? null : _onRegisterPressed,
              child: isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Register'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('Already have an account? Log in'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
