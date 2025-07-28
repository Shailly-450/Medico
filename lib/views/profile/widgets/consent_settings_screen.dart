import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/consent_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/consent.dart';

class ConsentSettingsScreen extends StatefulWidget {
  const ConsentSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ConsentSettingsScreen> createState() => _ConsentSettingsScreenState();
}

class _ConsentSettingsScreenState extends State<ConsentSettingsScreen> {
  final Set<String> _loadingConsentIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch consents when the screen is initialized
    Future.microtask(() {
      Provider.of<ConsentViewModel>(context, listen: false).fetchConsents();
    });
  }

  void _handleConsentAction(BuildContext context, ConsentViewModel viewModel, consent, bool grant) async {
    setState(() {
      _loadingConsentIds.add(consent.id);
    });
    final result = await viewModel.giveOrUpdateConsent({
      'type': consent.type.toString().split('.').last,
      'granted': grant,
      'details': consent.detailedDescription,
    });
    setState(() {
      _loadingConsentIds.remove(consent.id);
    });
    if (result['success'] == true) {
      // Optimistically update the local consent status
      viewModel.updateConsentStatus(consent.id, grant);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(grant ? 'Consent granted.' : 'Consent revoked.'),
          backgroundColor: grant ? Colors.green : Colors.red,
        ),
      );
    } else {
      // On error, reload the list to ensure consistency
      await viewModel.fetchConsents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update consent'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsentViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.consentItems.isEmpty) {
          return const Center(child: Text('No consents found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.consentItems.length,
          separatorBuilder: (context, idx) => const Divider(height: 24),
          itemBuilder: (context, idx) {
            final consent = viewModel.consentItems[idx];
            final isLoading = _loadingConsentIds.contains(consent.id);
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: consent.status == ConsentStatus.granted
                          ? Colors.green.withAlpha((0.15 * 255).toInt())
                          : Colors.red.withAlpha((0.15 * 255).toInt()),
                      child: Icon(
                        viewModel.typeIcon(consent.type),
                        color: consent.status == ConsentStatus.granted ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(consent.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(consent.detailedDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                          if (consent.grantedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                'Granted on: ${consent.grantedAt!.toLocal().toString().split(".")[0].replaceFirst('T', ' ')}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    consent.status == ConsentStatus.granted
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.block),
                            label: isLoading ? const Text('') : const Text('Revoke'),
                            onPressed: isLoading ? null : () => _handleConsentAction(context, viewModel, consent, false),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                            label: isLoading ? const Text('') : const Text('Grant'),
                            onPressed: isLoading ? null : () => _handleConsentAction(context, viewModel, consent, true),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 