import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';

class UserClassificationScreen extends StatefulWidget {
  const UserClassificationScreen({super.key});

  @override
  State<UserClassificationScreen> createState() =>
      _UserClassificationScreenState();
}

class _UserClassificationScreenState extends State<UserClassificationScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  bool _hasProfileData = false;
  bool _showFullForm = false;

  static const _teal = Color(0xFF00897B);
  static const _tealDark = Color(0xFF00695C);
  static const _surface = Color(0xFFF8FFFE);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _checkUserProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _hasProfileData =
            profile['name'] != null && profile['name'].toString().isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
    _animController.forward();
  }

  void _navigateToUpload(Map<String, String> data) {
    Navigator.pushNamed(context, '/camera', arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _surface,
        body: const Center(
          child: CircularProgressIndicator(color: _teal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: _showFullForm
                    ? _buildUserTypeView()
                    : _hasProfileData
                    ? _buildQuickAnalysisView()
                    : _buildUserTypeView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal, _tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 20),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FluoroSense',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withOpacity(0.15),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.person_outline, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAnalysisView() {
    final _quickFormKey = GlobalKey<FormState>();
    String waterSource = _userProfile?['water_source']?.toString() ?? '';
    String toothpasteType = _userProfile?['toothpaste_type']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User identity card
        _buildUserCard(),
        const SizedBox(height: 28),

        _buildSectionHeader('Quick Analysis'),
        const SizedBox(height: 6),
        const Text(
          'Your profile is saved. Confirm these per-analysis details to proceed.',
          style: TextStyle(
            color: Color(0xFF78909C),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _quickFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFormLabel('Primary Water Source'),
                const SizedBox(height: 8),
                _buildDropdownField<String>(
                  hint: 'Select source',
                  icon: Icons.water_drop_outlined,
                  value: waterSource.isEmpty ? null : waterSource,
                  items: ['Well', 'RO', 'Ground', 'Other'],
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select a water source'
                      : null,
                  onChanged: (value) => waterSource = value ?? '',
                ),
                const SizedBox(height: 20),
                _buildFormLabel('Toothpaste Type / Brand'),
                const SizedBox(height: 8),
                _buildInputField(
                  hint: 'e.g. Colgate, Sensodyne…',
                  icon: Icons.cleaning_services_outlined,
                  initialValue: toothpasteType,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter toothpaste type'
                      : null,
                  onChanged: (value) => toothpasteType = value,
                ),
                const SizedBox(height: 28),
                _buildPrimaryButton(
                  label: 'Proceed to Image Selection',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () {
                    if (_quickFormKey.currentState!.validate()) {
                      final formData = {
                        'name': _userProfile!['name']?.toString() ?? '',
                        'age': _userProfile!['age']?.toString() ?? '',
                        'gender': _userProfile!['gender']?.toString() ?? '',
                        'water_source': waterSource,
                        'toothpaste_type': toothpasteType,
                      };
                      _navigateToUpload(formData);
                    }
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildSecondaryButton(
          label: 'Analyse for someone else',
          onPressed: () => setState(() => _showFullForm = true),
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    final name = _userProfile?['name']?.toString() ?? 'User';
    final age = _userProfile?['age']?.toString() ?? 'N/A';
    final gender = _userProfile?['gender']?.toString() ?? 'N/A';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_teal, _tealDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E2D),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Age $age · $gender',
                  style: const TextStyle(
                      color: Color(0xFF90A4AE), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: _teal, size: 14),
                SizedBox(width: 4),
                Text(
                  'Saved',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasProfileData && _showFullForm) ...[
          GestureDetector(
            onTap: () => setState(() => _showFullForm = false),
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios_new, size: 14, color: _teal),
                SizedBox(width: 6),
                Text(
                  'Back to Quick Analysis',
                  style: TextStyle(
                      color: _teal, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
        _buildSectionHeader('Select Profile Type'),
        const SizedBox(height: 8),
        const Text(
          'Choose the profile that best matches the person being analysed.',
          style: TextStyle(
            color: Color(0xFF78909C),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _buildTypeCard(
          icon: Icons.child_care_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF43A047),
          title: 'Pregnant / Caretaker',
          subtitle: 'For mothers or children under 9 years old',
          onTap: () {
            Navigator.pushNamed(
              context,
              '/maternal-child-form',
              arguments: {'is_self': !_showFullForm},
            );
          },
        ),
        const SizedBox(height: 14),
        _buildTypeCard(
          icon: Icons.person_outline,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1E88E5),
          title: 'General User (Age 9+)',
          subtitle: 'For adults and children aged 9 and above',
          onTap: () {
            Navigator.pushNamed(
              context,
              '/general-user-form',
              arguments: {'is_self': !_showFullForm},
            );
          },
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E2D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Color(0xFF90A4AE), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFB0BEC5), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A2E2D),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF37474F),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String hint,
    required IconData icon,
    required T? value,
    required List<String> items,
    required String? Function(T?)? validator,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      onChanged: onChanged,
      isExpanded: true,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A2E2D)),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF90A4AE)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF90A4AE), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0ECEB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map((label) =>
          DropdownMenuItem(value: label as T, child: Text(label)))
          .toList(),
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    String? initialValue,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A2E2D)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF90A4AE), size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0ECEB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _teal,
          side: const BorderSide(color: _teal, width: 1.5),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}