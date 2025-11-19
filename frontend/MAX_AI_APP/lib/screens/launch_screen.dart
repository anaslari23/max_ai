import 'package:flutter/material.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00101A),
              Color(0xFF003840),
              Color(0xFF00A9A5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.wifi, color: Colors.white70),
                    Text(
                      'MAX Awake',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.mic_none, color: Colors.white70),
                  ],
                ),
              ),
              const Spacer(),
              _PulsingAvatar(),
              const SizedBox(height: 24),
              const Text(
                'Say "Hey Max" or tap to speak',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to face unlock settings
                      },
                      icon: const Icon(Icons.face_retouching_natural, color: Colors.white70),
                      label: const Text(
                        'Face unlock',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to PIN unlock settings
                      },
                      icon: const Icon(Icons.pin, color: Colors.white70),
                      label: const Text(
                        'PIN unlock',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          width: 220,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
              backgroundColor: const Color(0xFF00BFA6),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/listening');
            },
            child: const Text(
              'Tap to Speak',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF00E0C6), Color(0xFF003840)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.4),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.circle, size: 16, color: Colors.white70),
        ),
      ),
    );
  }
}
