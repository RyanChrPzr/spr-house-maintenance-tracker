import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vendor/domain/vendor_profile_model.dart';

class VendorCardWidget extends ConsumerWidget {
  const VendorCardWidget({
    super.key,
    required this.vendor,
    this.onBook,
    this.onTap,
  });

  final VendorProfileModel vendor;
  final VoidCallback? onBook;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      label: '${vendor.name}, ${vendor.services.join(', ')}, '
          '${vendor.completedJobsCount} jobs completed, '
          '${_priceRangeText()}, '
          '${vendor.isAvailable ? "Available" : "Unavailable"}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                CircleAvatar(
                  radius: 40,
                  backgroundImage: vendor.avatarUrl != null
                      ? NetworkImage(vendor.avatarUrl!)
                      : null,
                  child: vendor.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + availability badge row
                      Row(
                        children: [
                          Expanded(
                            child: Text(vendor.name,
                                style: theme.textTheme.titleMedium),
                          ),
                          _AvailabilityBadge(isAvailable: vendor.isAvailable),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Services chips
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: vendor.services
                            .map((s) => Chip(
                                  label: Text(s,
                                      style: theme.textTheme.labelSmall),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 4),

                      // Price range
                      Text(_priceRangeText(),
                          style: theme.textTheme.bodySmall),

                      // Jobs count
                      Text(
                        vendor.completedJobsCount == 0
                            ? 'New vendor — no completed jobs yet.'
                            : '${vendor.completedJobsCount} jobs completed',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),

                      // Book button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: vendor.isAvailable ? onBook : null,
                          child: const Text('Book'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _priceRangeText() {
    if (vendor.priceRangeMin != null && vendor.priceRangeMax != null) {
      return '₱${vendor.priceRangeMin!.toStringAsFixed(0)} – '
          '₱${vendor.priceRangeMax!.toStringAsFixed(0)} per visit';
    }
    return 'Price not set';
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isAvailable ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
