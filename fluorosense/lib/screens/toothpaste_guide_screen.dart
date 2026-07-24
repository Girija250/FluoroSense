import 'package:flutter/material.dart';

class ToothpasteGuideScreen extends StatelessWidget {
  const ToothpasteGuideScreen({super.key});

  static const _teal = Color(0xFF00897B);
  static const _tealLight = Color(0xFF4DB6AC);
  static const _tealDark = Color(0xFF00695C);

  static const _ingredients = [
    _Ingredient(
      name: 'Sodium Fluoride',
      formula: 'NaF',
      detail: 'Most common fluoride compound in toothpaste',
    ),
    _Ingredient(
      name: 'Sodium Monofluorophosphate',
      formula: 'Na₂PO₃F',
      detail: 'Releases fluoride ions on brushing',
    ),
    _Ingredient(
      name: 'Stannous Fluoride',
      formula: 'SnF₂',
      detail: 'Also helps reduce sensitivity & bacteria',
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
                        'Toothpaste Guide',
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
                          child: const Icon(Icons.cleaning_services_rounded,
                              color: _teal, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identifying Fluoridated Toothpaste',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Check the active ingredients on the tube',
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
                    'Active Fluoride Ingredients',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF455A64),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Ingredient list
                  ...List.generate(_ingredients.length, (i) {
                    final ing = _ingredients[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _IngredientCard(ingredient: ing, index: i),
                    );
                  }),

                  const SizedBox(height: 10),

                  // Tip banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.green.withOpacity(0.18), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'If you find any of these ingredients listed, the toothpaste is fluoridated. Look for concentrations between 1000–1500 ppm F for adults.',
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

class _Ingredient {
  final String name;
  final String formula;
  final String detail;
  const _Ingredient(
      {required this.name, required this.formula, required this.detail});
}

class _IngredientCard extends StatelessWidget {
  final _Ingredient ingredient;
  final int index;
  const _IngredientCard({required this.ingredient, required this.index});

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
              child: Text(
                ingredient.formula,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ingredient.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF90A4AE),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Fluoridated',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}