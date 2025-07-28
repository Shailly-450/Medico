import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import '../../viewmodels/family_members_view_model.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({Key? key}) : super(key: key);

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  bool _loading = true;
  String? _error;
  Set<String> _deletingIds = {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final vm = context.read<FamilyMembersViewModel>();
    final result = await vm.fetchFamilyMembersOnline();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] != true) {
        _error = result['message'] ?? 'Failed to load family members';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<FamilyMembersViewModel>().members;
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        title: const Text(
          'Family Members',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, ),
            onPressed: () async {
              final vm = context.read<FamilyMembersViewModel>();
              final result = await showDialog<Map<String, dynamic>?>(
                context: context,
                builder: (ctx) => _AddFamilyMemberDialog(),
              );
              if (result != null) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                );
                final apiResult = await vm.addFamilyMemberOnline(result);
                Navigator.of(context).pop();
                if (!context.mounted) return;
                if (apiResult['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Family member added!')),
                  );
                  _fetch();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(apiResult['message'] ?? 'Failed to add family member')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : members.isEmpty
                  ? const Center(child: Text('No family members'))
                  : ListView.separated(
                      itemCount: members.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(
                            member.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            member.role,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey, size: 26),
                                onPressed: () async {
                                  final vm = context.read<FamilyMembersViewModel>();
                                  final result = await showDialog<Map<String, dynamic>?>(
                                    context: context,
                                    builder: (ctx) => _AddFamilyMemberDialog(
                                      initial: {
                                        'name': member.name,
                                        'role': member.role,
                                        // Relationship and gender are not in FamilyMember, so leave blank
                                        'relationship': '',
                                        'gender': '',
                                      },
                                    ),
                                  );
                                  if (result != null) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => const Center(child: CircularProgressIndicator()),
                                    );
                                    final apiResult = await vm.updateFamilyMemberOnline(member.id, result);
                                    Navigator.of(context).pop();
                                    if (!context.mounted) return;
                                    if (apiResult['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Family member updated!')),
                                      );
                                      setState(() {}); // Refresh UI
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(apiResult['message'] ?? 'Failed to update family member')),
                                      );
                                    }
                                  }
                                },
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 26),
                                tooltip: 'Delete',
                                onPressed: _deletingIds.contains(member.id)
                                    ? null
                                    : () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Family Member'),
                                            content: Text('Are you sure you want to delete ${member.name}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          setState(() {
                                            _deletingIds.add(member.id);
                                          });
                                          final vm = context.read<FamilyMembersViewModel>();
                                          final apiResult = await vm.deleteFamilyMemberOnline(member.id);
                                          if (!context.mounted) return;
                                          setState(() {
                                            _deletingIds.remove(member.id);
                                          });
                                          if (apiResult['success'] != true) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(apiResult['message'] ?? 'Failed to remove family member')),
                                            );
                                          }
                                          // Always refresh the list after delete
                                          _fetch();
                                        }
                                      },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          onTap: () {},
                        );
                      },
                    ),
    );
  }
}

class _FamilyMember {
  final String name;
  final String role;
  final String imageUrl;
  const _FamilyMember({required this.name, required this.role, required this.imageUrl});
}

class _AddFamilyMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const _AddFamilyMemberDialog({this.initial});
  @override
  State<_AddFamilyMemberDialog> createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<_AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _role;
  late String _relationship;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _name = widget.initial?['name'] ?? '';
    _role = widget.initial?['role'] ?? '';
    _relationship = widget.initial?['relationship'] ?? '';
    _gender = widget.initial?['gender'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Family Member' : 'Edit Family Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                onSaved: (v) => _name = v ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _role.isNotEmpty ? _role : null,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'dependent', child: Text('Dependent')),
                  DropdownMenuItem(value: 'independent', child: Text('Independent')),
                ],
                onChanged: (v) => setState(() => _role = v ?? ''),
                validator: (v) => v == null || v.isEmpty ? 'Select role' : null,
                onSaved: (v) => _role = v ?? '',
              ),
              TextFormField(
                initialValue: _relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                validator: (v) => v == null || v.isEmpty ? 'Enter relationship' : null,
                onSaved: (v) => _relationship = v ?? '',
              ),
              TextFormField(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (v) => v == null || v.isEmpty ? 'Enter gender' : null,
                onSaved: (v) => _gender = v ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.pop(context, {
                'name': _name,
                'role': _role,
                'relationship': _relationship,
                'gender': _gender,
              });
            }
          },
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
} 