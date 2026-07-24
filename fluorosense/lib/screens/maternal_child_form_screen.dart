import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';

// ─── Responsive Breakpoints & Helpers ────────────────────────────────────────
class _Responsive {
  final double width;
  final double height;

  const _Responsive({required this.width, required this.height});

  factory _Responsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return _Responsive(width: size.width, height: size.height);
  }

  /// Small phone: width < 360 (e.g. iPhone SE 1st gen, Galaxy A03s)
  bool get isSmall => width < 360;

  /// Medium phone: 360 ≤ width < 600 (most Android mid-range, standard iPhones)
  bool get isMedium => width >= 360 && width < 600;

  /// Large: tablet / landscape
  bool get isLarge => width >= 600;

  // ── Adaptive values ────────────────────────────────────────────────────────

  /// Horizontal page padding
  double get hPad => isSmall ? 14.0 : isMedium ? 20.0 : 28.0;

  /// Vertical page padding (top)
  double get vPadTop => isSmall ? 16.0 : 24.0;

  /// Vertical page padding (bottom)
  double get vPadBottom => isSmall ? 24.0 : 32.0;

  /// Section header title font size
  double get headerTitleSize => isSmall ? 20.0 : isMedium ? 24.0 : 28.0;

  /// Section header subtitle font size
  double get headerSubtitleSize => isSmall ? 12.5 : 14.0;

  /// Step label font size
  double get stepLabelSize => isSmall ? 11.0 : 12.0;

  /// Gap between card fields
  double get fieldGap => isSmall ? 12.0 : 16.0;

  /// Card inner padding
  double get cardPadding => isSmall ? 14.0 : 20.0;

  /// Card border radius
  double get cardRadius => isSmall ? 16.0 : 20.0;

  /// Button height
  double get buttonHeight => isSmall ? 48.0 : 54.0;

  /// Button border radius
  double get buttonRadius => isSmall ? 13.0 : 16.0;

  /// Button font size
  double get buttonFontSize => isSmall ? 14.0 : 15.0;

  /// Input field vertical padding
  double get inputVerticalPadding => isSmall ? 14.0 : 18.0;

  /// Input field horizontal padding
  double get inputHorizontalPadding => isSmall ? 12.0 : 16.0;

  /// Input label font size
  double get inputLabelSize => isSmall ? 13.0 : 14.0;

  /// Input icon size
  double get inputIconSize => isSmall ? 18.0 : 20.0;

  /// Input border radius
  double get inputRadius => isSmall ? 12.0 : 14.0;

  /// Gap between header and card
  double get sectionGap => isSmall ? 20.0 : 28.0;

  /// Gap between card and CTA
  double get ctaGap => isSmall ? 20.0 : 28.0;

  /// Gap between step indicator and header
  double get stepGap => isSmall ? 18.0 : 24.0;

  /// AppBar title font sizes
  double get appBarBrandSize => isSmall ? 10.0 : 11.0;
  double get appBarTitleSize => isSmall ? 15.0 : 17.0;
}

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _AppColors {
  static const teal = Color(0xFF00897B);
  static const tealLight = Color(0xFFE0F2F1);
  static const tealDark = Color(0xFF00695C);
  static const surface = Color(0xFFF8FFFE);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1A2E2C);
  static const textSecondary = Color(0xFF6B8885);
  static const border = Color(0xFFDDEDEB);
  static const error = Color(0xFFD32F2F);
}

// ─── Responsive input decoration ─────────────────────────────────────────────
InputDecoration _fieldDecoration(
    String label, {
      IconData? icon,
      required _Responsive r,
    }) =>
    InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: _AppColors.textSecondary,
        fontSize: r.inputLabelSize,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: _AppColors.textSecondary, size: r.inputIconSize)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: r.inputHorizontalPadding,
        vertical: r.inputVerticalPadding,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.inputRadius),
        borderSide: const BorderSide(color: _AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.inputRadius),
        borderSide: const BorderSide(color: _AppColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.inputRadius),
        borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.inputRadius),
        borderSide: const BorderSide(color: _AppColors.error, width: 2),
      ),
    );

// ─── Main Widget ──────────────────────────────────────────────────────────────
class MaternalChildFormScreen extends StatefulWidget {
  const MaternalChildFormScreen({super.key});

  @override
  State<MaternalChildFormScreen> createState() =>
      _MaternalChildFormScreenState();
}

class _MaternalChildFormScreenState extends State<MaternalChildFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  bool _isPrefilled = false;
  bool _initialized = false;

  String _name = '',
      _age = '',
      _gender = '',
      _waterSource = '',
      _toothpasteType = '';
  String _milkIntake = '', _sugarLevels = '', _toothpasteSwallowing = '';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadPrefilledData();
    }
  }

  void _loadPrefilledData() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['prefilled'] == true) {
      final profile = args['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        _isPrefilled = true;
        _name = profile['name']?.toString() ?? '';
        _age = profile['age']?.toString() ?? '';
        _gender = profile['gender']?.toString() ?? '';
        _waterSource = profile['water_source']?.toString() ?? '';
        _toothpasteType = profile['toothpaste_type']?.toString() ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _Responsive.of(context);
    final totalPages = _isPrefilled ? 1 : 2;
    return Scaffold(
      backgroundColor: _AppColors.surface,
      appBar: _buildAppBar(context, r),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _isPrefilled
                ? [_buildExposureDetailsPage(totalPages: totalPages, r: r)]
                : [
              _buildPersonalDetailsPage(totalPages: totalPages, r: r),
              _buildExposureDetailsPage(totalPages: totalPages, r: r),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, _Responsive r) {
    return AppBar(
      backgroundColor: _AppColors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      // On very small screens, reduce toolbar height slightly
      toolbarHeight: r.isSmall ? 52 : kToolbarHeight,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FluoroSense',
            style: TextStyle(
              fontSize: r.appBarBrandSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.4,
              color: Colors.white70,
            ),
          ),
          Text(
            'Maternal / Child Details',
            style: TextStyle(
              fontSize: r.appBarTitleSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Page indicator ──────────────────────────────────────────────────────────
  Widget _buildStepIndicator(int currentPage, int totalPages) {
    if (totalPages == 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _AppColors.teal : _AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Section heading ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String step,
    required String title,
    required String subtitle,
    required _Responsive r,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: TextStyle(
            color: _AppColors.teal,
            fontSize: r.stepLabelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: r.isSmall ? 3 : 4),
        Text(
          title,
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontSize: r.headerTitleSize,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: r.isSmall ? 6 : 8),
        Text(
          subtitle,
          style: TextStyle(
            color: _AppColors.textSecondary,
            fontSize: r.headerSubtitleSize,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Personal Details Page ───────────────────────────────────────────────────
  Widget _buildPersonalDetailsPage({
    required int totalPages,
    required _Responsive r,
  }) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.hPad,
          r.vPadTop,
          r.hPad,
          r.vPadBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(0, totalPages),
            SizedBox(height: r.stepGap),
            _buildSectionHeader(
              step: 'STEP 1 OF 2',
              title: 'Personal\nDetails',
              subtitle: 'Basic information to personalise\nyour fluorosis analysis.',
              r: r,
            ),
            SizedBox(height: r.sectionGap),

            // ── Card ──────────────────────────────────────────────────────────
            _FormCard(
              padding: r.cardPadding,
              radius: r.cardRadius,
              children: [
                TextFormField(
                  decoration: _fieldDecoration(
                    'Full Name',
                    icon: Icons.person_outline,
                    r: r,
                  ),
                  style: TextStyle(fontSize: r.inputLabelSize + 1),
                  validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                  onSaved: (v) => _name = v!,
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: r.fieldGap),
                TextFormField(
                  decoration: _fieldDecoration(
                    'Age',
                    icon: Icons.calendar_today_outlined,
                    r: r,
                  ),
                  style: TextStyle(fontSize: r.inputLabelSize + 1),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Please enter an age' : null,
                  onSaved: (v) => _age = v!,
                ),
                SizedBox(height: r.fieldGap),
                _StyledDropdown<String>(
                  label: 'Gender',
                  icon: Icons.wc_outlined,
                  initialValue: _gender.isEmpty ? null : _gender,
                  items: const ['Male', 'Female', 'Other'],
                  onChanged: (v) => setState(() => _gender = v ?? ''),
                  r: r,
                ),
                SizedBox(height: r.fieldGap),
                _StyledDropdown<String>(
                  label: 'Primary Water Source',
                  icon: Icons.water_drop_outlined,
                  initialValue: _waterSource.isEmpty ? null : _waterSource,
                  items: const ['Well', 'RO', 'Ground', 'Other'],
                  onChanged: (v) => setState(() => _waterSource = v ?? ''),
                  r: r,
                ),
                SizedBox(height: r.fieldGap),
                TextFormField(
                  decoration: _fieldDecoration(
                    'Toothpaste Type / Brand',
                    icon: Icons.brush_outlined,
                    r: r,
                  ),
                  style: TextStyle(fontSize: r.inputLabelSize + 1),
                  onSaved: (v) => _toothpasteType = v ?? '',
                ),
              ],
            ),
            SizedBox(height: r.ctaGap),

            // ── CTA ───────────────────────────────────────────────────────────
            _PrimaryButton(
              label: 'Continue',
              trailing: Icons.arrow_forward_rounded,
              height: r.buttonHeight,
              radius: r.buttonRadius,
              fontSize: r.buttonFontSize,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      );
    });
  }

  // ── Exposure Details Page ───────────────────────────────────────────────────
  Widget _buildExposureDetailsPage({
    required int totalPages,
    required _Responsive r,
  }) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.hPad,
          r.vPadTop,
          r.hPad,
          r.vPadBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepIndicator(_isPrefilled ? 0 : 1, totalPages),
            SizedBox(height: r.stepGap),
            _buildSectionHeader(
              step: _isPrefilled ? 'DETAILS' : 'STEP 2 OF 2',
              title: 'Exposure\nDetails',
              subtitle:
              'Dietary & hygiene habits that\ninfluence fluoride exposure.',
              r: r,
            ),
            SizedBox(height: r.sectionGap),

            _FormCard(
              padding: r.cardPadding,
              radius: r.cardRadius,
              children: [
                TextFormField(
                  decoration: _fieldDecoration(
                    'Daily Milk Intake (ml)',
                    icon: Icons.local_drink_outlined,
                    r: r,
                  ),
                  style: TextStyle(fontSize: r.inputLabelSize + 1),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _milkIntake = v ?? '',
                ),
                SizedBox(height: r.fieldGap),
                TextFormField(
                  decoration: _fieldDecoration(
                    'Daily Sugar Intake (g)',
                    icon: Icons.bakery_dining_outlined,
                    r: r,
                  ),
                  style: TextStyle(fontSize: r.inputLabelSize + 1),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _sugarLevels = v ?? '',
                ),
                SizedBox(height: r.fieldGap),
                _StyledDropdown<String>(
                  label: 'Toothpaste Swallowing Habit',
                  icon: Icons.sentiment_neutral_outlined,
                  initialValue: _toothpasteSwallowing.isEmpty
                      ? null
                      : _toothpasteSwallowing,
                  items: const ['Never', 'Sometimes', 'Always'],
                  onChanged: (v) =>
                      setState(() => _toothpasteSwallowing = v ?? ''),
                  r: r,
                ),
              ],
            ),
            SizedBox(height: r.ctaGap),

            // ── Actions ───────────────────────────────────────────────────────
            Row(
              children: [
                if (!_isPrefilled) ...[
                  Expanded(
                    child: _SecondaryButton(
                      label: 'Back',
                      leading: Icons.arrow_back_rounded,
                      height: r.buttonHeight,
                      radius: r.buttonRadius,
                      fontSize: r.buttonFontSize,
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  SizedBox(width: r.isSmall ? 8 : 12),
                ],
                Expanded(
                  flex: 2,
                  child: _PrimaryButton(
                    label: 'Select Image',
                    trailing: Icons.camera_alt_rounded,
                    height: r.buttonHeight,
                    radius: r.buttonRadius,
                    fontSize: r.buttonFontSize,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        final formData = {
                          'name': _name,
                          'age': _age,
                          'gender': _gender,
                          'water_source': _waterSource,
                          'toothpaste_type': _toothpasteType,
                          'milk_intake': _milkIntake,
                          'sugar_levels': _sugarLevels,
                          'toothpaste_swallowing': _toothpasteSwallowing,
                        };

                        if (!_isPrefilled) {
                          final args =
                              ModalRoute.of(context)?.settings.arguments;
                          if (args is Map<String, dynamic> &&
                              args['is_self'] == true) {
                            try {
                              await ApiService().updateProfile({
                                'name': _name,
                                'age': _age,
                                'gender': _gender,
                                'water_source': _waterSource,
                                'toothpaste_type': _toothpasteType,
                                'user_type': 'Pregnant/Caretaker (<9yrs)',
                              });
                            } catch (_) {}
                          }
                        }

                        if (mounted) {
                          Navigator.pushNamed(
                            context,
                            '/camera',
                            arguments: formData,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

/// Elegant white card that wraps form fields
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  final double padding;
  final double radius;

  const _FormCard({
    required this.children,
    this.padding = 20,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Dropdown that matches the field decoration style
class _StyledDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? initialValue;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final _Responsive r;

  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: _fieldDecoration(label, icon: icon, r: r),
      value: initialValue,
      icon: Icon(
        Icons.expand_more_rounded,
        color: _AppColors.textSecondary,
        size: r.inputIconSize,
      ),
      borderRadius: BorderRadius.circular(r.inputRadius),
      isExpanded: true, // prevents overflow on narrow screens
      items: items
          .map((v) => DropdownMenuItem<T>(
        value: v,
        child: Text(
          v.toString(),
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontSize: r.inputLabelSize + 1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// Teal filled primary action button
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? trailing;
  final VoidCallback onPressed;
  final double height;
  final double radius;
  final double fontSize;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.trailing,
    this.height = 54,
    this.radius = 16,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              Icon(trailing, size: fontSize + 3),
            ],
          ],
        ),
      ),
    );
  }
}

/// Outlined secondary button for Back actions
class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? leading;
  final VoidCallback onPressed;
  final double height;
  final double radius;
  final double fontSize;

  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.height = 54,
    this.radius = 16,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _AppColors.teal,
          side: const BorderSide(color: _AppColors.teal, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: fontSize + 3),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}