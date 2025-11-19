import 'package:flutter/material.dart';

class ActionsPermissionsScreen extends StatelessWidget {
  const ActionsPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = [
      'Contacts',
      'SMS',
      'Phone',
      'Location',
      'Calendar',
      'Notifications',
      'Accessibility Service (Android)',
      'Siri Shortcuts (iOS)',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Actions & Permissions'),
        backgroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final status = index.isEven ? 'Not granted' : 'Granted';
          final isGranted = status == 'Granted';
          return _PermissionRow(
            title: permissions[index],
            status: status,
            isGranted: isGranted,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: permissions.length,
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String title;
  final String status;
  final bool isGranted;

  const _PermissionRow({
    required this.title,
    required this.status,
    required this.isGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.lock_outline,
            color: isGranted ? Colors.greenAccent : Colors.amberAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Needed so Max can perform this action securely.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranted ? Colors.grey[800] : Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: Text(isGranted ? 'Explain' : 'Grant'),
          ),
        ],
      ),
    );
  }
}
