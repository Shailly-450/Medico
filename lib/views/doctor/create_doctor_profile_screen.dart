import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';

class CreateDoctorProfileScreen extends StatefulWidget {
  const CreateDoctorProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateDoctorProfileScreen> createState() => _CreateDoctorProfileScreenState();
}

class _CreateDoctorProfileScreenState extends State<CreateDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Profile fields
  String _name = '';
  String _phone = '';
  String _languages = '';
  String _consultationFee = '';
  bool _isVerified = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ApiService.getProfile();
    if (result['success'] == true) {
      final data = result['data'] ?? {};
      final profile = data['profile'] ?? {};
      final doctorProfile = data['doctorProfile'] ?? {};
      setState(() {
        _name = profile['name'] ?? '';
        _phone = profile['phone'] ?? '';
        _languages = (doctorProfile['languages'] as List?)?.join(', ') ?? '';
        _consultationFee = doctorProfile['consultationFee']?.toString() ?? '';
        _isVerified = doctorProfile['isVerified'] ?? false;
        _isOnline = doctorProfile['isOnline'] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Failed to load profile.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final profileData = {
      'profile': {
        'name': _name,
        'phone': _phone,
      },
      'doctorProfile': {
        'languages': _languages.split(',').map((e) => e.trim()).toList(),
        'consultationFee': num.tryParse(_consultationFee) ?? 0,
        'isVerified': _isVerified,
        'isOnline': _isOnline,
      },
    };
    final result = await ApiService.updateProfile(profileData);
    setState(() {
      _isSaving = false;
    });
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _error = result['message'] ?? 'Failed to update profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Doctor Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (v) => _name = v,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      onChanged: (v) => _phone = v,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _languages,
                      decoration: const InputDecoration(labelText: 'Languages (comma separated)'),
                      onChanged: (v) => _languages = v,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _consultationFee,
                      decoration: const InputDecoration(labelText: 'Consultation Fee'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _consultationFee = v,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Verified'),
                      value: _isVerified,
                      onChanged: (v) => setState(() => _isVerified = v),
                    ),
                    SwitchListTile(
                      title: const Text('Online'),
                      value: _isOnline,
                      onChanged: (v) => setState(() => _isOnline = v),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 