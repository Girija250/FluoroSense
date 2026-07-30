import 'package:flutter/material.dart';

class AboutFluorosisScreen extends StatelessWidget {
  const AboutFluorosisScreen({super.key});

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
                'About Fluorosis',
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
                    Icons.local_hospital_rounded,
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
              delegate: SliverChildListDelegate([
                _InfoCard(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF006D6D),
                  title: 'What is Dental Fluorosis?',
                  body:
                  'Dental fluorosis is a common, painless condition characterized by changes in the appearance of tooth enamel, white spots or streaks, and intrinsic tooth discoloration. It\'s caused by overexposure to fluoride during the first eight years of life, the time when most permanent teeth are being formed.',
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.medical_information_outlined,
                  iconColor: const Color(0xFFE07B39),
                  title: 'Symptoms',
                  body:
                  'Fluorosis can be classified as questionable, very mild, mild, moderate, or severe. The symptoms range from small, white, lacy markings on the enamel to severe, with staining, pitting, and a rough enamel surface.',
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.science_outlined,
                  iconColor: const Color(0xFF7B68EE),
                  title: 'Causes',
                  body:
                  'The most common cause of fluorosis is the intake of excessive fluoride during early childhood, primarily through drinking water with high fluoride concentrations and the use of fluoride-containing dental products such as toothpaste and mouth rinses. Accidental swallowing of highly fluoridated toothpaste, especially by young children during tooth brushing, can also contribute to increased fluoride exposure and the development of fluorosis.',
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF4A6060),
            ),
          ),
        ],
      ),
    );
  }
}