import 'package:flutter/material.dart';

class FluorideFoodGuideScreen extends StatelessWidget {
  const FluorideFoodGuideScreen({super.key});

  static const _teal = Color(0xFF00897B);
  static const _tealLight = Color(0xFF4DB6AC);
  static const _tealDark = Color(0xFF00695C);

  static const _foods = [
    _FoodItem(emoji: '🍵', name: 'Tea', note: 'High natural fluoride'),
    _FoodItem(emoji: '🦐', name: 'Seafood', note: 'Ocean minerals'),
    _FoodItem(emoji: '🍇', name: 'Grapes', note: 'Pesticide residue'),
    _FoodItem(emoji: '🥔', name: 'Potatoes', note: 'Soil absorption'),
    _FoodItem(emoji: '🥬', name: 'Spinach', note: 'Leafy greens'),
    _FoodItem(emoji: '🌾', name: 'Oatmeal', note: 'Fluoridated water use'),
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
                        'Fluoride Food Guide',
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
                            color: _teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded,
                              color: _teal, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fluoride-Rich Foods',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Common foods that may contain fluoride',
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
                    'Food Sources',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF455A64),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Food grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _foods.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (_, i) => _FoodCard(item: _foods[i]),
                  ),

                  const SizedBox(height: 24),

                  // Tip banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _teal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: _teal.withOpacity(0.18), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_outlined,
                            color: _teal, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Consuming these foods in moderation is generally safe. High fluoride intake over time may pose health risks.',
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

class _FoodItem {
  final String emoji;
  final String name;
  final String note;
  const _FoodItem({required this.emoji, required this.name, required this.note});
}

class _FoodCard extends StatelessWidget {
  final _FoodItem item;
  const _FoodCard({required this.item});

  static const _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.note,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF90A4AE),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}