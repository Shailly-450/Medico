import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import '../../viewmodels/family_members_view_model.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({Key? key}) : super(key: key);

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
            onPressed: () {
              // Demo: Add a dummy member
              final vm = context.read<FamilyMembersViewModel>();
              vm.addMember(FamilyMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'New Member',
                role: 'Relative',
                imageUrl: 'https://randomuser.me/api/portraits/lego/1.jpg',
              ));
            },
          ),
        ],
      ),
      body: members.isEmpty
          ? const Center(child: Text('No family members'))
          : ListView.separated(
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(member.imageUrl),
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
                        onPressed: () {},
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 26),
                        tooltip: 'Delete',
                        onPressed: () async {
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
                            context.read<FamilyMembersViewModel>().removeMember(member.id);
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