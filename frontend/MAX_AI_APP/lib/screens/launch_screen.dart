import 'package:flutter/material.dart';
import 'dart:math' as math;

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050813), // Deep Space
              Color(0xFF0B1221), // Slightly lighter
              Color(0xFF001F24), // Dark Teal hint
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusIcon(icon: Icons.wifi, label: "ONLINE"),
                    const Text(
                      'J.A.R.V.I.S',
                      style: TextStyle(
                        color: Colors.white54,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    _StatusIcon(icon: Icons.battery_full, label: "100%"),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Central Core
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return _BreathingCore(controller: _controller);
                },
              ),
              
              const SizedBox(height: 40),
              
              // Status Text
              const Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  color: Color(0xFF00E0C6),
                  fontSize: 14,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: Color(0xFF00E0C6), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Awaiting voice command...',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              
              const Spacer(),
              
              // Action Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/listening'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E0C6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF00E0C6).withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E0C6).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.mic, color: Color(0xFF00E0C6)),
                        SizedBox(width: 12),
                        Text(
                          'INITIALIZE VOICE',
                          style: TextStyle(
                            color: Color(0xFF00E0C6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white30, fontSize: 10),
        ),
      ],
    );
  }
}

class _BreathingCore extends StatelessWidget {
  final AnimationController controller;

  const _BreathingCore({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow Ring 1
          Transform.scale(
            scale: 1.0 + (controller.value * 0.2),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E0C6).withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E0C6).withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Outer Glow Ring 2 (Rotating)
          Transform.rotate(
            angle: controller.value * 2 * math.pi,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E0C6).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          // Inner Core
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(
                color: const Color(0xFF00E0C6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E0C6).withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.power_settings_new, color: Color(0xFF00E0C6), size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
