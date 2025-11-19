import 'package:flutter/material.dart';

class SettingsPersonaScreen extends StatelessWidget {
  const SettingsPersonaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Settings & Persona'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ToneSliderSection(),
          SizedBox(height: 16),
          _MemoryToggleSection(),
          SizedBox(height: 16),
          _VoiceSelectionSection(),
          SizedBox(height: 16),
          _PrivacyDashboardSection(),
          SizedBox(height: 16),
          _PersonaExamplesSection(),
        ],
      ),
    );
  }
}

class _ToneSliderSection extends StatelessWidget {
  const _ToneSliderSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tone',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjust how Max talks to you.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Formal', style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text('Friendly', style: TextStyle(color: Colors.white, fontSize: 12)),
              Text('Playful', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Slider(
            value: 0.5,
            onChanged: (_) {},
            activeColor: Colors.tealAccent,
            inactiveColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}

class _MemoryToggleSection extends StatelessWidget {
  const _MemoryToggleSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Memory Mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              _PillOption(label: 'Off', selected: false),
              _PillOption(label: 'Local', selected: true),
              _PillOption(label: 'Cloud encrypted', selected: false),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose where Max stores what it remembers about you.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _VoiceSelectionSection extends StatelessWidget {
  const _VoiceSelectionSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Voice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: const [
              _PillOption(label: 'Male', selected: false),
              _PillOption(label: 'Female', selected: true),
              _PillOption(label: 'Custom', selected: false),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick how Max sounds. Custom voices can be uploaded securely.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PrivacyDashboardSection extends StatelessWidget {
  const _PrivacyDashboardSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Privacy Dashboard',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Manage what Max knows about you.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: const Text('Clear memory'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: const Text('Export data'),
          ),
        ],
      ),
    );
  }
}

class _PersonaExamplesSection extends StatelessWidget {
  const _PersonaExamplesSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Persona examples',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PersonaPreview(
            title: 'Focused Planner',
            description: 'Keeps you on schedule, minimal small talk.',
          ),
          SizedBox(height: 8),
          _PersonaPreview(
            title: 'Hype Coach',
            description: 'High-energy, motivational responses with playful tone.',
          ),
          SizedBox(height: 8),
          _PersonaPreview(
            title: 'Calm Companion',
            description: 'Soft, reassuring messages and gentle reminders.',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final bool selected;

  const _PillOption({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
      ),
      selectedColor: Colors.tealAccent,
      backgroundColor: const Color(0xFF020617),
    );
  }
}

class _PersonaPreview extends StatelessWidget {
  final String title;
  final String description;

  const _PersonaPreview({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
