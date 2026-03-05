import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../vendor_notifier.dart';

class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Set<String> _selectedServices = {};
  XFile? _selectedPhoto;
  String? _nameError;
  String? _phoneError;
  String? _servicesError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = picked);
    }
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Full name is required'
          : null;
      _phoneError = _phoneController.text.trim().isEmpty
          ? 'Contact number is required'
          : null;
      _servicesError = _selectedServices.isEmpty
          ? 'Select at least one service type'
          : null;
    });
    if (_selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo')),
      );
    }
    return _nameError == null &&
        _phoneError == null &&
        _servicesError == null &&
        _selectedPhoto != null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(vendorOnboardingNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppConstants.statusError,
          ),
        );
      }
      if (next.hasValue && !next.isLoading) {
        context.go('/vendor/profile-setup');
      }
    });

    final isLoading =
        ref.watch(vendorOnboardingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 16),

            // Service Types (FilterChip multi-select)
            Text(
              'Service Types *',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_servicesError != null)
              Text(
                _servicesError!,
                style: TextStyle(
                  color: AppConstants.statusError,
                  fontSize: 12,
                ),
              ),
            Wrap(
              spacing: 8,
              children: AppConstants.serviceTypes.map((type) {
                final selected = _selectedServices.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedServices.add(type);
                      } else {
                        _selectedServices.remove(type);
                      }
                      _servicesError = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Contact Number
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Contact Number *',
                errorText: _phoneError,
              ),
            ),
            const SizedBox(height: 16),

            // Profile Photo
            if (_selectedPhoto != null)
              Center(
                child: FutureBuilder<Uint8List>(
                  future: _selectedPhoto!.readAsBytes(),
                  builder: (_, snap) => snap.hasData
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: MemoryImage(snap.data!),
                        )
                      : const CircleAvatar(
                          radius: 40,
                          child: Icon(Icons.person),
                        ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                _selectedPhoto == null ? 'Upload Photo *' : 'Change Photo',
              ),
            ),

            const SizedBox(height: 32),

            // Submit CTA — full width
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_validate()) {
                          final userId = Supabase
                              .instance.client.auth.currentUser!.id;
                          ref
                              .read(vendorOnboardingNotifierProvider.notifier)
                              .submitOnboarding(
                                userId: userId,
                                name: _nameController.text.trim(),
                                services: _selectedServices.toList(),
                                phone: _phoneController.text.trim(),
                                photo: _selectedPhoto!,
                              );
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Start Receiving Jobs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
