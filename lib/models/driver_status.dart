import 'package:flutter/material.dart';

class DriverStatus {
  final String status;
  final DateTime lastUpdated;
  final double? confidence;
  final String? driverId;

  DriverStatus({
    required this.status,
    required this.lastUpdated,
    this.confidence,
    this.driverId,
  });

  factory DriverStatus.fromMap(Map<dynamic, dynamic> map) {
    return DriverStatus(
      status: map['status']?.toString() ?? 'UNKNOWN',
      lastUpdated: map['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['last_updated'] is int)
                  ? map['last_updated']
                  : int.tryParse(map['last_updated'].toString()) ?? 0,
            )
          : DateTime.now(),
      confidence: map['confidence'] != null
          ? double.tryParse(map['confidence'].toString())
          : null,
      driverId: map['driver_id']?.toString(),
    );
  }

  bool get isDanger => status.toUpperCase() == 'DANGER';
  bool get isWarning => status.toUpperCase() == 'WARNING';
  bool get isSafe => status.toUpperCase() == 'SAFE';
  bool get isNormal => status.toUpperCase() == 'NORMAL';

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'DANGER':
        return const Color(0xFFFF1744);
      case 'WARNING':
        return const Color(0xFFFF9100);
      case 'SAFE':
      case 'NORMAL':
        return const Color(0xFF00E676);
      default:
        return const Color(0xFF90A4AE);
    }
  }
}
