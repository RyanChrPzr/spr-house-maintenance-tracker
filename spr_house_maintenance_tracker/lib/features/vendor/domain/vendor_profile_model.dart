import 'package:flutter/foundation.dart';

@immutable
class VendorProfileModel {
  const VendorProfileModel({
    required this.id,
    required this.name,
    required this.services,
    required this.isAvailable,
    required this.isSuspended,
    required this.completedJobsCount,
    this.priceRangeMin,
    this.priceRangeMax,
    this.qrphUrl,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final List<String> services;
  final double? priceRangeMin;
  final double? priceRangeMax;
  final String? qrphUrl;
  final String? avatarUrl;
  final bool isAvailable;
  final bool isSuspended;
  final int completedJobsCount;

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle optional profiles join: present when fetched via fetchVendorProfile,
    // absent when constructing from insert response (createVendorProfile returns void).
    final profilesMap = json['profiles'] as Map<String, dynamic>?;
    return VendorProfileModel(
      id: json['id'] as String,
      name: profilesMap?['name'] as String? ?? '',
      services: List<String>.from(json['services'] as List? ?? []),
      priceRangeMin: (json['price_range_min'] as num?)?.toDouble(),
      priceRangeMax: (json['price_range_max'] as num?)?.toDouble(),
      qrphUrl: json['qrph_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? false,
      completedJobsCount: json['completed_jobs_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    // name intentionally excluded — it lives in profiles table, not vendor_extensions
    'services': services,
    'price_range_min': priceRangeMin,
    'price_range_max': priceRangeMax,
    'qrph_url': qrphUrl,
    'avatar_url': avatarUrl,
    'is_available': isAvailable,
    'is_suspended': isSuspended,
    'completed_jobs_count': completedJobsCount,
  };
}
