import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/driver_status.dart';
import '../services/firebase_service.dart';
import '../widgets/status_card.dart';
import '../widgets/danger_overlay.dart';
import 'alerts_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  DriverStatus? _currentStatus;
  bool _showDanger = false;

  late AnimationController _pulseController;
  late AnimationController _flashController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _flashAnimation = Tween<double>(begin: 0.0, end: 0.55).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _handleStatusChange(DriverStatus? status) {
    if (status == null) return;
    setState(() {
      _currentStatus = status;
      _showDanger = status.isDanger;
    });

    if (status.isDanger) {
      _flashController.repeat(reverse: true);
      HapticFeedback.heavyImpact();
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Color(0xFFFF1744)),
      );
    } else {
      _flashController.stop();
      _flashController.reset();
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DriverStatus?>(
      stream: _firebaseService.driverStatusStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != _currentStatus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStatusChange(snapshot.data);
          });
        }

        final status = snapshot.data ?? _currentStatus;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: Stack(
            children: [
              // ── Background gradient ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      const Color(0xFF1A1F35),
                      const Color(0xFF0A0E1A),
                    ],
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(status),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildStatusHero(status),
                            const SizedBox(height: 28),
                            _buildStatsRow(status),
                            const SizedBox(height: 28),
                            _buildAlertsButton(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Danger flash overlay ─────────────────────────────────────
              if (_showDanger)
                DangerOverlay(animation: _flashAnimation),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DriverStatus? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.07),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.remove_red_eye_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DrowsyDriver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Live Monitoring Dashboard',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHero(DriverStatus? status) {
    final isLoading = status == null;
    final isDanger = status?.isDanger ?? false;
    final statusText = status?.status ?? '...';
    final statusColor = status?.statusColor ?? const Color(0xFF90A4AE);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isDanger ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(isDanger ? 0.25 : 0.12),
              statusColor.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: statusColor.withOpacity(isDanger ? 0.7 : 0.3),
            width: isDanger ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(isDanger ? 0.4 : 0.1),
              blurRadius: isDanger ? 40 : 20,
              spreadRadius: isDanger ? 4 : 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Icon ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.15),
                border: Border.all(
                  color: statusColor.withOpacity(0.6),
                  width: 3,
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Icon(
                      isDanger
                          ? Icons.warning_amber_rounded
                          : status!.isWarning
                              ? Icons.watch_later_rounded
                              : Icons.check_circle_rounded,
                      color: statusColor,
                      size: 48,
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'DRIVER STATUS',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            if (isDanger) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF1744).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚠️  IMMEDIATE ACTION REQUIRED',
                  style: TextStyle(
                    color: Color(0xFFFF6D7E),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(DriverStatus? status) {
    return Row(
      children: [
        Expanded(
          child: StatusCard(
            icon: Icons.speed_rounded,
            label: 'Confidence',
            value: status?.confidence != null
                ? '${(status!.confidence! * 100).toStringAsFixed(1)}%'
                : '--',
            color: const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatusCard(
            icon: Icons.access_time_rounded,
            label: 'Last Update',
            value: status != null
                ? _formatTime(status.lastUpdated)
                : '--',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatusCard(
            icon: Icons.person_rounded,
            label: 'Driver ID',
            value: status?.driverId ?? 'N/A',
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AlertsHistoryScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text(
              'View Alert History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
