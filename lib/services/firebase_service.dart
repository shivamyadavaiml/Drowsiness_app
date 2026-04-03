import 'package:firebase_database/firebase_database.dart';
import '../models/driver_status.dart';
import '../models/alert_record.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ── Driver Status Stream ──────────────────────────────────────────────────
  Stream<DriverStatus?> driverStatusStream() {
    return _db
        .ref('driver_status')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return null;
          if (data is Map) {
            return DriverStatus.fromMap(data);
          }
          // If the node is just a string like "DANGER"
          return DriverStatus(
            status: data.toString(),
            lastUpdated: DateTime.now(),
          );
        });
  }

  // ── Alerts History Stream ─────────────────────────────────────────────────
  Stream<List<AlertRecord>> alertsHistoryStream() {
    return _db
        .ref('alerts_history')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return <AlertRecord>[];
          if (data is Map) {
            final records = data.entries.map((entry) {
              if (entry.value is Map) {
                return AlertRecord.fromMap(
                    entry.key.toString(), entry.value as Map);
              }
              return null;
            }).whereType<AlertRecord>().toList();

            // Sort descending by timestamp (newest first)
            records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return records;
          }
          return <AlertRecord>[];
        });
  }
}
