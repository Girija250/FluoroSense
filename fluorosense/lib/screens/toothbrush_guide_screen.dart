import 'package:flutter/material.dart';

class ToothbrushGuideScreen extends StatelessWidget {
  const ToothbrushGuideScreen({super.key});

  static const _teal = Color(0xFF00897B);
  static const _tealLight = Color(0xFF4DB6AC);
  static const _tealDark = Color(0xFF00695C);

  static const _tips = [
    _Tip(
      icon: Icons.timer_outlined,
      title: 'Brush for Two Minutes',
      detail: 'Spend at least two minutes brushing, twice a day. Use a timer to ensure you brush long enough.',
    ),
    _Tip(
      icon: Icons.brush_outlined,
      title: 'Use Proper Technique',
      detail: 'Use gentle, circular motions to clean the front, back, and chewing surfaces of all teeth. Avoid sawing back and forth.',
    ),
    _Tip(
      icon: Icons.sync_alt_outlined,
      title: 'Replace Your Toothbrush',
      detail: 'Replace your toothbrush every 3-4 months, or sooner if the bristles are frayed. A worn toothbrush won\'t clean your teeth properly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_tealLight, _tealDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Toothbrush Guide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _teal.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.brush_rounded,
                              color: _teal, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Proper Brushing Habits',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Technique and consistency are key',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF90A4AE),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Key Brushing Tips',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF455A64),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tips list
                  ...List.generate(_tips.length, (i) {
                    final tip = _tips[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TipCard(tip: tip, index: i),
                    );
                  }),

                  const SizedBox(height: 10),

                  // Tip banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.18), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Consider a soft-bristled brush to prevent gum damage. Electric toothbrushes can also be more effective at removing plaque.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF37474F),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final String title;
  final String detail;
  const _Tip(
      {required this.icon, required this.title, required this.detail});
}

class _TipCard extends StatelessWidget {
  final _Tip tip;
  final int index;
  const _TipCard({required this.tip, required this.index});

  static const _colors = [
    Color(0xFF00897B),
    Color(0xFF26A69A),
    Color(0xFF4DB6AC),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(tip.icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF90A4AE),
                    height: 1.4,
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