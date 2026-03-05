import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vendor/presentation/vendor_provider.dart';
import '../../../vendor/domain/vendor_profile_model.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key, required this.vendorId});
  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorProfileProvider(vendorId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
      ),
      body: vendorAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Could not load vendor profile.',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(vendorProfileProvider(vendorId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (vendor) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero photo
              if (vendor.avatarUrl != null)
                Image.network(
                  vendor.avatarUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _photoFallback(),
                )
              else
                _photoFallback(),

              // Profile details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(vendor.name, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),

                    // Availability badge
                    Row(
                      children: [
                        Icon(Icons.circle,
                            size: 12,
                            color: vendor.isAvailable
                                ? Colors.green
                                : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          vendor.isAvailable ? 'Available' : 'Unavailable',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: vendor.isAvailable
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Services
                    Text('Services', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: vendor.services
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Price range
                    Text('Price Range', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      _priceRangeText(vendor),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Jobs count
                    Text('Experience', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      vendor.completedJobsCount == 0
                          ? 'New vendor — no completed jobs yet.'
                          : '${vendor.completedJobsCount} jobs completed',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Book CTA
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: vendor.isAvailable
                            ? () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Booking — Story 3.2')),
                                )
                            : null,
                        child: const Text('Book This Vendor'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoFallback() => Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.person, size: 80, color: Colors.grey),
      );

  String _priceRangeText(VendorProfileModel vendor) {
    if (vendor.priceRangeMin != null && vendor.priceRangeMax != null) {
      return '₱${vendor.priceRangeMin!.toStringAsFixed(0)} – '
          '₱${vendor.priceRangeMax!.toStringAsFixed(0)} per visit';
    }
    return 'Price not set';
  }
}
