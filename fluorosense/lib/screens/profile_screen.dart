import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';
import 'package:fluorosense/services/auth_service.dart';
import 'package:fluorosense/services/suggestion_service.dart';
import 'package:intl/intl.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _AppColors {
  static const teal = Color(0xFF00897B);
  static const tealLight = Color(0xFFE0F2F1);
  static const tealDark = Color(0xFF00695C);
  static const surface = Color(0xFFF8FFFE);
  static const textPrimary = Color(0xFF1A2E2C);
  static const textSecondary = Color(0xFF6B8885);
  static const border = Color(0xFFDDEDEB);
  static const error = Color(0xFFD32F2F);

  static const healthy = Color(0xFF4CAF50);
  static const mild = Color(0xFFFFC107);
  static const moderate = Color(0xFFFF9800);
  static const severe = Color(0xFFF44336);
}

// ─── Shared Input Decoration ──────────────────────────────────────────────────
InputDecoration _fieldDec(String label, {IconData? icon}) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(
    color: _AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
  prefixIcon: icon != null
      ? Icon(icon, color: _AppColors.textSecondary, size: 20)
      : null,
  filled: true,
  fillColor: Colors.white,
  contentPadding:
  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: _AppColors.border, width: 1.5),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: _AppColors.teal, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: _AppColors.error, width: 1.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: _AppColors.error, width: 2),
  ),
);

// ─── Main Screen ──────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _email = '',
      _password = '',
      _name = '',
      _age = '',
      _gender = '',
      _waterSource = '',
      _toothpasteType = '',
      _residentCity = '';
  bool _isUpdating = false;
  bool _isEditing = false;

  List<dynamic> _reports = [];
  List<dynamic> _filteredReports = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  bool _hasProfileData = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadProfileAndReports();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool _isFieldPresent(String? value) {
    return value != null && value.isNotEmpty;
  }

  Future<void> _loadProfileAndReports() async {
    try {
      final profile = await _apiService.getUserProfile();
      final reports = await _apiService.getReports();
      if (!mounted) return;
      setState(() {
        _email = profile['email'] ?? '';
        _name = profile['name'] ?? '';
        _age = profile['age']?.toString() ?? '';
        _gender = profile['gender'] ?? '';
        _waterSource = profile['water_source'] ?? '';
        _toothpasteType = profile['toothpaste_type'] ?? '';
        _residentCity = profile['resident_city'] ?? '';
        _reports = reports;
        _filteredReports = reports;
        _hasProfileData = _isFieldPresent(_name);
        _isLoading = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      if (mounted) {
        _showSnack('Error loading data: $e', isError: true);
        setState(() => _isLoading = false);
        _fadeCtrl.forward();
      }
    }
  }

  DateTime _parseDateTime(dynamic ts) {
    if (ts == null) return DateTime.now();
    try {
      return ts is String ? DateTime.parse(ts) : DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  void _filterReportsByDate() {
    if (_selectedDateRange == null) {
      setState(() => _filteredReports = _reports);
      return;
    }
    setState(() {
      _filteredReports = _reports.where((r) {
        final t = _parseDateTime(r['timestamp']);
        return t.isAfter(_selectedDateRange!.start) &&
            t.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isUpdating = true);
      try {
        final data = <String, dynamic>{
          'email': _email,
          'name': _name,
          'age': _age,
          'gender': _gender,
          'water_source': _waterSource,
          'toothpaste_type': _toothpasteType,
          'resident_city': _residentCity,
        };
        if (_password.isNotEmpty) data['password'] = _password;
        await _apiService.updateProfile(data);
        if (mounted) {
          _showSnack('Profile updated successfully');
          setState(() {
            _isEditing = false;
            _hasProfileData = _isFieldPresent(_name);
          });
        }
      } catch (e) {
        if (mounted) _showSnack('Update failed: $e', isError: true);
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _AppColors.error : _AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScaffold();

    return Scaffold(
      backgroundColor: _AppColors.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [_buildSliverAppBar()],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hasProfileData && !_isEditing
                    ? _buildProfileSummary()
                    : _buildProfileEditForm(),
                const SizedBox(height: 32),
                _buildDivider('Health Overview'),
                const SizedBox(height: 16),
                _buildOverallHealthSummary(),
                const SizedBox(height: 32),
                _buildHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Scaffold _buildLoadingScaffold() => Scaffold(
    backgroundColor: _AppColors.surface,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _AppColors.teal),
          const SizedBox(height: 16),
          Text(
            'Loading profile…',
            style: TextStyle(
                color: _AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    ),
  );

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: _AppColors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
        const EdgeInsets.fromLTRB(20, 0, 56, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FluoroSense',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),
            const Text(
              'Profile & History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00897B), Color(0xFF00695C)],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section divider with label ─────────────────────────────────────────────
  Widget _buildDivider(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: _AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: _AppColors.border, thickness: 1),
        ),
      ],
    );
  }

  // ── Profile Summary (Read-only) ────────────────────────────────────────────
  Widget _buildProfileSummary() {
    return _ElevatedCard(
      child: Column(
        children: [
          // Avatar + name row
          Row(
            children: [
              _Avatar(initial: _isFieldPresent(_name) ? _name[0].toUpperCase() : 'U'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _ChipButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onTap: () => setState(() => _isEditing = true),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: _AppColors.border),
          const SizedBox(height: 16),

          // Detail rows
          _ProfileDetailRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: _isFieldPresent(_age) ? _age : '—',
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.person_outline,
            label: 'Gender',
            value: _isFieldPresent(_gender) ? _gender : '—',
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.water_drop_outlined,
            label: 'Water Source',
            value: _isFieldPresent(_waterSource) ? _waterSource : '—',
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.brush_outlined,
            label: 'Toothpaste',
            value: _isFieldPresent(_toothpasteType) ? _toothpasteType : '—',
          ),
          const SizedBox(height: 12),
          _ProfileDetailRow(
            icon: Icons.location_city,
            label: 'Resident place till 8 years of age',
            value: _isFieldPresent(_residentCity) ? _residentCity : '—',
          ),
        ],
      ),
    );
  }

  // ── Profile Edit Form ──────────────────────────────────────────────────────
  Widget _buildProfileEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _hasProfileData ? 'Edit Profile' : 'Complete Profile',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (_hasProfileData)
                _ChipButton(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  onTap: () => setState(() => _isEditing = false),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ElevatedCard(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _email,
                  decoration:
                  _fieldDec('Email', icon: Icons.mail_outline_rounded),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Enter email' : null,
                  onSaved: (v) => _email = v!,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _name,
                  decoration:
                  _fieldDec('Full Name', icon: Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _age,
                  decoration: _fieldDec('Age',
                      icon: Icons.calendar_today_outlined),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _age = v!,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  decoration:
                  _fieldDec('Gender', icon: Icons.wc_outlined),
                  value: _gender.isEmpty ? null : _gender,
                  icon: const Icon(Icons.expand_more_rounded,
                      color: _AppColors.textSecondary),
                  borderRadius: BorderRadius.circular(14),
                  items: ['Male', 'Female', 'Other']
                      .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l,
                          style: const TextStyle(
                              fontSize: 15,
                              color: _AppColors.textPrimary))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _gender = v ?? ''),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  decoration: _fieldDec('Water Source',
                      icon: Icons.water_drop_outlined),
                  value: _waterSource.isEmpty ? null : _waterSource,
                  icon: const Icon(Icons.expand_more_rounded,
                      color: _AppColors.textSecondary),
                  borderRadius: BorderRadius.circular(14),
                  items: ['Well', 'RO', 'Ground', 'Other']
                      .map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l,
                          style: const TextStyle(
                              fontSize: 15,
                              color: _AppColors.textPrimary))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _waterSource = v ?? ''),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _toothpasteType,
                  decoration: _fieldDec('Toothpaste Type',
                      icon: Icons.brush_outlined),
                  onSaved: (v) => _toothpasteType = v!,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _residentCity,
                  decoration: _fieldDec('Resident place till 8 years of age (City, State of India)',
                      icon: Icons.location_city),
                  onSaved: (v) => _residentCity = v!,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: _fieldDec(
                      'New Password (leave blank to keep)',
                      icon: Icons.lock_outline_rounded),
                  obscureText: true,
                  onSaved: (v) => _password = v!,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _AppColors.teal.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isUpdating
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ))
                  : Text(
                _hasProfileData ? 'Update Profile' : 'Save Profile',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Health Summary ─────────────────────────────────────────────────────────
  Widget _buildOverallHealthSummary() {
    final data = SuggestionService.getOverallSummary(_reports);
    final Color statusColor = Color(data['color']);
    final stats = data['stats'] as Map<String, dynamic>?;
    final recs = data['recommendations'] as List<String>;
    final trend = data['trend'] as String;

    final (IconData trendIcon, String trendText, Color trendColor) =
    switch (trend) {
      'improving' => (
      Icons.trending_up_rounded,
      'Improving',
      _AppColors.healthy
      ),
      'worsening' => (
      Icons.trending_down_rounded,
      'Worsening',
      _AppColors.severe
      ),
      _ => (Icons.trending_flat_rounded, 'Stable', Colors.grey),
    };

    return _ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + trend
          Row(
            children: [
              _StatusChip(label: data['overallStatus'], color: statusColor),
              const Spacer(),
              if (_reports.isNotEmpty)
                Row(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      trendText,
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data['summary'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: _AppColors.textPrimary,
            ),
          ),

          // Stats bar
          if (stats != null && stats['total'] > 0) ...[
            const SizedBox(height: 20),
            _buildStatsBar(stats),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatPill(
                    label: 'Healthy',
                    count: stats['noFluorosis'],
                    color: _AppColors.healthy),
                _StatPill(
                    label: 'Mild',
                    count: stats['mild'],
                    color: _AppColors.mild),
                _StatPill(
                    label: 'Moderate',
                    count: stats['moderate'],
                    color: _AppColors.moderate),
                _StatPill(
                    label: 'Severe',
                    count: stats['severe'],
                    color: _AppColors.severe),
              ],
            ),
          ],

          // Recommendations
          if (recs.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: _AppColors.border),
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: _AppColors.mild, size: 17),
                SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recs.map(
                  (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded,
                        color: _AppColors.teal, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(
                            fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsBar(Map<String, dynamic> stats) {
    final total = stats['total'] as int;
    if (total == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          if (stats['noFluorosis'] > 0)
            Expanded(
              flex: stats['noFluorosis'],
              child: Container(height: 10, color: _AppColors.healthy),
            ),
          if (stats['mild'] > 0)
            Expanded(
              flex: stats['mild'],
              child: Container(height: 10, color: _AppColors.mild),
            ),
          if (stats['moderate'] > 0)
            Expanded(
              flex: stats['moderate'],
              child: Container(height: 10, color: _AppColors.moderate),
            ),
          if (stats['severe'] > 0)
            Expanded(
              flex: stats['severe'],
              child: Container(height: 10, color: _AppColors.severe),
            ),
        ],
      ),
    );
  }

  // ── History Section ────────────────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ANALYSIS HISTORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: _AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: _AppColors.teal),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDateRange = picked);
                  _filterReportsByDate();
                }
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.date_range_rounded,
                        size: 16, color: _AppColors.teal),
                    SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_selectedDateRange != null) ...[
          const SizedBox(height: 10),
          Chip(
            label: Text(
              '${DateFormat('MMM d').format(_selectedDateRange!.start)} – ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
              style: const TextStyle(fontSize: 12, color: _AppColors.tealDark),
            ),
            backgroundColor: _AppColors.tealLight,
            deleteIconColor: _AppColors.tealDark,
            onDeleted: () {
              setState(() => _selectedDateRange = null);
              _filterReportsByDate();
            },
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ],
        const SizedBox(height: 16),
        if (_filteredReports.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.history_rounded,
                      size: 48, color: _AppColors.border),
                  const SizedBox(height: 12),
                  const Text(
                    'No reports found',
                    style: TextStyle(
                        color: _AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredReports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => _buildReportCard(_filteredReports[i]),
          ),
      ],
    );
  }

  Widget _buildReportCard(dynamic report) {
    final suggestion = SuggestionService.getSuggestion(
        report['classification']?.toString() ?? '');
    final Color reportColor = Color(suggestion['color']);
    final tips = (suggestion['tips'] as List<String>).take(3).toList();

    return _ElevatedCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              report['image_url'],
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: _AppColors.tealLight,
                child: const Icon(Icons.broken_image_rounded,
                    color: _AppColors.teal, size: 24),
              ),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                    color: reportColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report['classification'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              DateFormat('d MMM yyyy · HH:mm')
                  .format(_parseDateTime(report['timestamp'])),
              style: const TextStyle(
                  fontSize: 12, color: _AppColors.textSecondary),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(report['confidence'] * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: reportColor,
                ),
              ),
              const Text(
                'confidence',
                style: TextStyle(
                    fontSize: 10, color: _AppColors.textSecondary),
              ),
            ],
          ),
          children: [
            const Divider(color: _AppColors.border),
            const SizedBox(height: 10),
            Text(
              suggestion['description'],
              style: const TextStyle(
                  fontSize: 13, height: 1.6, color: _AppColors.textPrimary),
            ),
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Tips',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right_rounded,
                        color: reportColor, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                            fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _ElevatedCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: padding == null
            ? Padding(padding: const EdgeInsets.all(20), child: child)
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BFA5), Color(0xFF00695C)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ChipButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _AppColors.tealLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _AppColors.tealDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _AppColors.tealDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileDetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: _AppColors.teal, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                color: _AppColors.textSecondary, fontSize: 14),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: _AppColors.textSecondary),
        ),
      ],
    );
  }
}