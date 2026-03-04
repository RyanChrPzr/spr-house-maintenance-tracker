import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../auth_notifier.dart';

/// Role selection screen — navigated to after successful registration.
///
/// Reached via [context.go], so there is no back navigation.
/// Calls [AuthNotifier.createProfile] then navigates to the appropriate
/// dashboard based on the chosen role.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  bool _homeownerLoading = false;
  bool _vendorLoading = false;

  Future<void> _selectRole(String userType) async {
    final isHomeowner = userType == AppConstants.userTypeHomeowner;
    setState(() {
      if (isHomeowner) {
        _homeownerLoading = true;
      } else {
        _vendorLoading = true;
      }
    });

    try {
      await ref.read(authNotifierProvider.notifier).createProfile(userType);
      if (!mounted) return;
      if (isHomeowner) {
        context.go('/homeowner');
      } else {
        context.go('/vendor');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppConstants.statusError,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _homeownerLoading = false;
          _vendorLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnyLoading = _homeownerLoading || _vendorLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Who are you?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppConstants.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your role to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: isAnyLoading ? null : () => _selectRole(AppConstants.userTypeHomeowner),
                child: _homeownerLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('I am a Homeowner'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isAnyLoading ? null : () => _selectRole(AppConstants.userTypeVendor),
                child: _vendorLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('I am a Vendor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
