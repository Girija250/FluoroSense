import 'package:flutter/material.dart';
import 'package:fluorosense/services/api_service.dart';

class GeneralUserFormScreen extends StatefulWidget {
  const GeneralUserFormScreen({super.key});

  @override
  State<GeneralUserFormScreen> createState() => _GeneralUserFormScreenState();
}

class _GeneralUserFormScreenState extends State<GeneralUserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '',
      _age = '',
      _gender = '',
      _waterSource = '',
      _toothpasteType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text(
          'Personal Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006D6D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step indicator
                _StepIndicator(currentStep: 1, totalSteps: 2, label: 'Step 1 of 2 — About You'),
                const SizedBox(height: 24),

                _FormCard(
                  children: [
                    _buildSectionLabel('Basic Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Please enter your age' : null,
                      onSaved: (v) => _age = v!,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Gender',
                      icon: Icons.wc_rounded,
                      items: ['Male', 'Female', 'Other'],
                      value: _gender.isEmpty ? null : _gender,
                      onChanged: (v) => setState(() => _gender = v.toString()),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _FormCard(
                  children: [
                    _buildSectionLabel('Health Habits'),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Primary Water Source',
                      icon: Icons.water_drop_outlined,
                      items: ['Well', 'RO', 'Ground', 'Other'],
                      value: _waterSource.isEmpty ? null : _waterSource,
                      onChanged: (v) => setState(() => _waterSource = v.toString()),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Toothpaste Type / Brand',
                      icon: Icons.brush_outlined,
                      onSaved: (v) => _toothpasteType = v!,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final formData = {
                        'name': _name,
                        'age': _age,
                        'gender': _gender,
                        'water_source': _waterSource,
                        'toothpaste_type': _toothpasteType,
                      };

                      final args = ModalRoute.of(context)?.settings.arguments;
                      if (args is Map<String, dynamic> && args['is_self'] == true) {
                        try {
                          await ApiService().updateProfile({
                            'name': _name,
                            'age': _age,
                            'gender': _gender,
                            'water_source': _waterSource,
                            'toothpaste_type': _toothpasteType,
                            'user_type': 'Age 9+',
                          });
                        } catch (_) {}
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
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF006D6D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next: Select Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF006D6D),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF006D6D), size: 20),
        labelStyle: const TextStyle(color: Color(0xFF4A6060), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF0F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D6D), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<Object?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF006D6D), size: 20),
        labelStyle: const TextStyle(color: Color(0xFF4A6060), fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF0F7F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF006D6D), width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String label;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (i) {
            final active = i < currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF006D6D)
                      : const Color(0xFFD0E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4A6060),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}