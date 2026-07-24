import 'package:flutter/material.dart';

class AwarenessTipsScreen extends StatelessWidget {
  const AwarenessTipsScreen({super.key});

  static const List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF006D6D),
      'title': 'Monitor Fluoride Intake',
      'body':
      'Be aware of the fluoride concentration in your drinking water. Your local water district can provide this information. If you use well water, have it tested annually.',
    },
    {
      'icon': Icons.brush_rounded,
      'color': Color(0xFF2196A8),
      'title': 'Use Fluoride Toothpaste Properly',
      'body':
      'For children under 3, use a smear of toothpaste the size of a grain of rice. For children 3 to 6, use a pea-sized amount. Supervise brushing to ensure they spit out the toothpaste and don\'t swallow it.',
    },
    {
      'icon': Icons.medication_rounded,
      'color': Color(0xFFE07B39),
      'title': 'Fluoride Supplements',
      'body':
      'Only use fluoride supplements as prescribed by a doctor or dentist. They are recommended only for children living in areas with low fluoride in the water.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF006D6D),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Awareness Tips',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF005555), Color(0xFF009999)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment(0.8, -0.2),
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    size: 80,
                    color: Colors.white10,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final tip = _tips[index];
                  final color = tip['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TipCard(
                      number: index + 1,
                      icon: tip['icon'] as IconData,
                      color: color,
                      title: tip['title'] as String,
                      body: tip['body'] as String,
                    ),
                  );
                },
                childCount: _tips.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final int number;
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _TipCard({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF4A6060),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}