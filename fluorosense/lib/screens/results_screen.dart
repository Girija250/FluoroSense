import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluorosense/services/suggestion_service.dart';

class ResultsScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final String classification;
  final double confidence;

  const ResultsScreen({
    super.key,
    required this.imageBytes,
    required this.classification,
    required this.confidence,
  });

  static const _teal = Color(0xFF00897B);
  static const _tealDark = Color(0xFF00695C);
  static const _surface = Color(0xFFF8FFFE);

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle_outline_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = SuggestionService.getSuggestion(classification);
    final Color statusColor = Color(suggestion['color']);
    final tips = suggestion['tips'] as List<String>;

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible image header ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _tealDark,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withOpacity(0.2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child:
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Analysis Results',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes, fit: BoxFit.cover),
                  // Gradient overlay so title stays readable
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.transparent],
                        stops: [0.0, 0.6],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Status badge card ──
                  _buildStatusCard(suggestion, statusColor, context),
                  const SizedBox(height: 16),

                  // ── Description ──
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    iconColor: _teal,
                    title: 'What This Means',
                    child: Text(
                      suggestion['description'],
                      style: const TextStyle(
                          fontSize: 14, height: 1.6, color: Color(0xFF455A64)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Recommendations ──
                  _buildInfoCard(
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: const Color(0xFFFFA000),
                    title: 'Recommendations',
                    child: Column(
                      children: tips
                          .map((tip) => _buildTipRow(tip, statusColor))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Done CTA ──
                  _buildDoneButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      Map<String, dynamic> suggestion,
      Color statusColor,
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconData(suggestion['icon']),
              color: statusColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion['title'],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Confidence: ',
                      style: TextStyle(fontSize: 13, color: Color(0xFF90A4AE)),
                    ),
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Mini confidence arc could go here — keeping it clean
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: confidence,
                  strokeWidth: 4,
                  backgroundColor: statusColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Text(
                  '${(confidence * 100).toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2E2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F4F4)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTipRow(String tip, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: Color(0xFF455A64)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00897B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
    );
  }
}