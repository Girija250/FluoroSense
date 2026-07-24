import 'package:flutter/material.dart';
import 'package:fluorosense/screens/user_classification_screen.dart';
import 'package:fluorosense/services/api_service.dart';

class ScreeningQuestionsScreen extends StatefulWidget {
  const ScreeningQuestionsScreen({super.key});

  @override
  _ScreeningQuestionsScreenState createState() =>
      _ScreeningQuestionsScreenState();
}

class _ScreeningQuestionsScreenState extends State<ScreeningQuestionsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _profile = {};
  bool _isLoading = true;

  bool? _siblingsHaveFluorides;
  bool? _neighborsHaveFluorides;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool _isFieldPresent(String? value) {
    return value != null && value.isNotEmpty;
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      if (!mounted) return;

      final siblingHistory = profile['sibling_fluorosis_history']?.toString();
      final neighborHistory = profile['neighbor_fluorosis_history']?.toString();

      if (_isFieldPresent(siblingHistory) && _isFieldPresent(neighborHistory)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const UserClassificationScreen(),
          ),
        );
        // Keep loading true to prevent the screen from building unnecessarily
        return;
      }

      setState(() {
        _profile = profile;
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

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : const Color(0xFF006D6D),
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  bool get _canProceed {
    final siblingQuestionNeeded = !_isFieldPresent(_profile['sibling_fluorosis_history']?.toString());
    final neighborQuestionNeeded = !_isFieldPresent(_profile['neighbor_fluorosis_history']?.toString());

    if (siblingQuestionNeeded && _siblingsHaveFluorides == null) return false;
    if (neighborQuestionNeeded && _neighborsHaveFluorides == null) return false;

    return true;
  }

  Future<void> _onContinue() async {
    final dataToUpdate = <String, dynamic>{};
    if (_siblingsHaveFluorides != null) {
      dataToUpdate['sibling_fluorosis_history'] = _siblingsHaveFluorides! ? 'Yes' : 'No';
    }
    if (_neighborsHaveFluorides != null) {
      dataToUpdate['neighbor_fluorosis_history'] = _neighborsHaveFluorides! ? 'Yes' : 'No';
    }

    if (dataToUpdate.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await _apiService.updateProfile(dataToUpdate);
      } catch (e) {
        if(mounted) {
          _showSnack('Failed to save your answers: $e', isError: true);
          setState(() => _isLoading = false);
        }
        return; // Don't proceed if update fails
      }
    }

    if(mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserClassificationScreen(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAFA),
        appBar: AppBar(
          title: const Text(
            'Screening Questions',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF006D6D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF006D6D))),
      );
    }

    final siblingQuestionNeeded = !_isFieldPresent(_profile['sibling_fluorosis_history']?.toString());
    final neighborQuestionNeeded = !_isFieldPresent(_profile['neighbor_fluorosis_history']?.toString());

    if (!siblingQuestionNeeded && !neighborQuestionNeeded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF006D6D)),
              const SizedBox(height: 16),
              const Text(
                'Information complete. Redirecting...',
                style: TextStyle(fontSize: 14, color: Color(0xFF4A6060)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text(
          'Screening Questions',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006D6D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006D6D).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF006D6D).withOpacity(0.15),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.quiz_rounded,
                        color: Color(0xFF006D6D),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Please answer the following to help us assess your risk profile.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF006D6D),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (siblingQuestionNeeded)
                _QuestionCard(
                  number: '01',
                  question: 'Do your siblings have dental fluorosis?',
                  value: _siblingsHaveFluorides,
                  onChanged: (val) =>
                      setState(() => _siblingsHaveFluorides = val),
                ),

                if (siblingQuestionNeeded)
                const SizedBox(height: 16),

                if(neighborQuestionNeeded)
                _QuestionCard(
                  number: '02',
                  question: 'Do your neighbours have dental fluorosis?',
                  value: _neighborsHaveFluorides,
                  onChanged: (val) =>
                      setState(() => _neighborsHaveFluorides = val),
                ),

                const Spacer(),

                // Progress indicator
                Row(
                  children: List.generate(2, (i) {
                    final answered = i == 0
                        ? _siblingsHaveFluorides != null
                        : _neighborsHaveFluorides != null;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i == 0 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: answered
                              ? const Color(0xFF006D6D)
                              : const Color(0xFFD0E8E8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: _canProceed ? _onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF006D6D),
                    disabledBackgroundColor: const Color(0xFFB2DFDF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String number;
  final String question;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.value,
    required this.onChanged,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D6D).withOpacity(0.5),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2E2E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AnswerChip(
                label: 'Yes',
                selected: value == true,
                onTap: () => onChanged(true),
              ),
              const SizedBox(width: 12),
              _AnswerChip(
                label: 'No',
                selected: value == false,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AnswerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF006D6D)
              : const Color(0xFFF0F7F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF006D6D)
                : const Color(0xFFD0E8E8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF4A6060),
          ),
        ),
      ),
    );
  }
}