import 'package:flutter/material.dart';
import 'package:fluorosense/screens/about_fluorosis_screen.dart';
import 'package:fluorosense/screens/awareness_tips_screen.dart';
import 'package:fluorosense/screens/steps_guide_screen.dart';
import 'package:fluorosense/screens/screening_questions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _teal = Color(0xFF00897B);
  static const _tealLight = Color(0xFF4DB6AC);
  static const _tealDark = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          // Custom header
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
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 24),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'FluoroSense',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.person_outline_rounded,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What would you\nlike to explore?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF263238),
                      height: 1.3,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose a section to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF90A4AE),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Top row — 2 cards
                  _buildCardRow(context),

                  const SizedBox(height: 16),

                  // Bottom wide cards
                  _NavCard(
                    icon: Icons.checklist_rounded,
                    label: 'Steps Guide',
                    description: 'Reduce fluoride exposure step by step',
                    accent: const Color(0xFF26A69A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StepsGuideScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NavCard(
                    icon: Icons.assignment_outlined,
                    label: 'Screening',
                    description: 'Answer questions to assess your risk level',
                    accent: const Color(0xFF00897B),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScreeningQuestionsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _NavCardCompact(
              icon: Icons.info_outline_rounded,
              label: 'About\nFluorosis',
              accent: const Color(0xFF4DB6AC),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutFluorosisScreen()),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _NavCardCompact(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Awareness\nTips',
              accent: const Color(0xFF00ACC1),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AwarenessTipsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _NavCardCompact extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _NavCardCompact({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF90A4AE),
                      height: 1.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}