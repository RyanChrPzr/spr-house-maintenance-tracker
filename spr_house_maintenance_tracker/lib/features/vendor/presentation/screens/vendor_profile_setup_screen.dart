import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../vendor_notifier.dart';

class VendorProfileSetupScreen extends ConsumerStatefulWidget {
  const VendorProfileSetupScreen({super.key});

  @override
  ConsumerState<VendorProfileSetupScreen> createState() =>
      _VendorProfileSetupScreenState();
}

class _VendorProfileSetupScreenState
    extends ConsumerState<VendorProfileSetupScreen> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  XFile? _qrphPhoto;
  String? _minPriceError;
  String? _maxPriceError;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  bool _validate() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();
    final minEmpty = minText.isEmpty;
    final maxEmpty = maxText.isEmpty;

    // Both empty is OK — user can skip pricing
    if (minEmpty && maxEmpty) {
      setState(() {
        _minPriceError = null;
        _maxPriceError = null;
      });
      return true;
    }

    // One filled, one empty — require both together
    if (minEmpty != maxEmpty) {
      setState(() {
        _minPriceError =
            minEmpty ? 'Both min and max prices are required together' : null;
        _maxPriceError =
            maxEmpty ? 'Both min and max prices are required together' : null;
      });
      return false;
    }

    // Both filled — validate numeric values
    final min = double.tryParse(minText);
    final max = double.tryParse(maxText);

    setState(() {
      _minPriceError = min == null || min <= 0 ? 'Enter a valid price' : null;
      _maxPriceError = max == null || max <= 0 ? 'Enter a valid price' : null;
    });

    if (_minPriceError != null || _maxPriceError != null) return false;

    if (min! >= max!) {
      setState(() => _minPriceError = 'Min price must be less than max price');
      return false;
    }

    return true;
  }

  Future<void> _pickQrphPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) setState(() => _qrphPhoto = picked);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(vendorOnboardingNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
      if (next.hasValue && !next.isLoading) {
        context.go('/vendor/dashboard');
      }
    });

    final isLoading = ref.watch(vendorOnboardingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Pricing'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Min Price
            TextField(
              controller: _minPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Min Price (₱) *',
                prefixText: '₱ ',
                errorText: _minPriceError,
              ),
            ),
            const SizedBox(height: 16),

            // Max Price
            TextField(
              controller: _maxPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Max Price (₱) *',
                prefixText: '₱ ',
                errorText: _maxPriceError,
              ),
            ),
            const SizedBox(height: 16),

            // QRPH Upload
            OutlinedButton.icon(
              onPressed: _pickQrphPhoto,
              icon: const Icon(Icons.qr_code),
              label: const Text('Upload QRPH Code (optional)'),
            ),
            if (_qrphPhoto != null) ...[
              const SizedBox(height: 4),
              Text(
                _qrphPhoto!.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 32),

            // Save & Continue CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_validate()) {
                          final minText = _minPriceController.text.trim();
                          final maxText = _maxPriceController.text.trim();
                          final priceMin = minText.isEmpty
                              ? null
                              : double.parse(minText);
                          final priceMax = maxText.isEmpty
                              ? null
                              : double.parse(maxText);

                          final userId =
                              Supabase.instance.client.auth.currentUser!.id;
                          ref
                              .read(vendorOnboardingNotifierProvider.notifier)
                              .submitPricingSetup(
                                userId: userId,
                                priceMin: priceMin,
                                priceMax: priceMax,
                                qrphPhoto: _qrphPhoto,
                              );
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Save & Continue'),
              ),
            ),
            const SizedBox(height: 8),

            // Skip CTA
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.go('/vendor/dashboard'),
                child: const Text('Skip for now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
