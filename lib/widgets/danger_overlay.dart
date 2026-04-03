import 'package:flutter/material.dart';

/// Pulsing red flash overlay shown when driver status is DANGER.
class DangerOverlay extends StatelessWidget {
  final Animation<double> animation;

  const DangerOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return IgnorePointer(
          child: Stack(
            children: [
              // Full-screen red tint
              Container(
                color: const Color(0xFFFF1744).withOpacity(animation.value),
              ),
              // Top red bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  color: const Color(0xFFFF1744),
                ),
              ),
              // Bottom red bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  color: const Color(0xFFFF1744),
                ),
              ),
              // Centered DANGER label
              Center(
                child: Opacity(
                  opacity: animation.value > 0.15 ? animation.value * 1.5 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1744).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFFF1744).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'DANGER DETECTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Driver may be drowsy!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
