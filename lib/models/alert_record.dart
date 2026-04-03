class AlertRecord {
  final String id;
  final String status;
  final String? imageUrl;
  final DateTime timestamp;
  final String? location;
  final double? confidence;

  AlertRecord({
    required this.id,
    required this.status,
    this.imageUrl,
    required this.timestamp,
    this.location,
    this.confidence,
  });

  factory AlertRecord.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertRecord(
      id: id,
      status: map['status']?.toString() ?? 'UNKNOWN',
      imageUrl: map['image_url']?.toString() ?? map['imageUrl']?.toString(),
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['timestamp'] is int)
                  ? map['timestamp']
                  : int.tryParse(map['timestamp'].toString()) ?? 0,
            )
          : DateTime.now(),
      location: map['location']?.toString(),
      confidence: map['confidence'] != null
          ? double.tryParse(map['confidence'].toString())
          : null,
    );
  }

  bool get isDanger => status.toUpperCase() == 'DANGER';
  bool get isWarning => status.toUpperCase() == 'WARNING';
}
