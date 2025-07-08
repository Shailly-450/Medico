import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/journey_tracker_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/journey_stage.dart';
import 'widgets/journey_card.dart';
import 'widgets/journey_timeline.dart';
import 'widgets/journey_progress_card.dart';
import 'widgets/stage_detail_dialog.dart';
import 'widgets/stage_edit_dialog.dart';
import 'widgets/stage_reorder_dialog.dart';
import 'widgets/add_stage_dialog.dart';
import 'widgets/journey_progress_tracker.dart';

class JourneyTrackerScreen extends StatelessWidget {
  const JourneyTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<JourneyTrackerViewModel>(
      viewModelBuilder: () => JourneyTrackerViewModel(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Medical Journey Tracker',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            if (model.selectedJourney != null) ...[
              IconButton(
                icon: const Icon(Icons.swap_vert, color: Colors.white),
                tooltip: 'Reorder Stages',
                onPressed: () {
                  _showReorderDialog(context, model);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Add New Stage',
                onPressed: () {
                  _showAddStageDialog(context, model);
                },
              ),
            ],
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              tooltip: 'Add New Journey',
              onPressed: () {
                // TODO: Implement add new journey functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add new journey feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8F5E8), // Light mint green
                Color(0xFFF0F8F0), // Very light sage
                Color(0xFFE6F3E6), // Soft green tint
                Color(0xFFF5F9F5), // Almost white with green tint
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: model.isBusy
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : model.errorMessage != null
                  ? _buildErrorWidget(context, model)
                  : _buildBody(context, model),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, JourneyTrackerViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Journeys',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            model.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              model.clearError();
              model.init();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, JourneyTrackerViewModel model) {
    if (model.journeys.isEmpty) {
      return _buildEmptyState(context);
    }

    return SafeArea(
      child: Column(
        children: [
          // Journey Selection
          _buildJourneySelection(context, model),
          
          // Selected Journey Details
          if (model.selectedJourney != null) ...[
            Expanded(
              child: _buildJourneyDetails(context, model),
            ),
          ] else ...[
            Expanded(
              child: _buildJourneyList(context, model),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32),
                    const Color(0xFF4CAF50),
                    const Color(0xFF66BB6A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.timeline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Medical Journeys Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your medical treatment journeys will appear here.\nTrack your progress through consultation, testing, and surgery stages.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32),
                    const Color(0xFF4CAF50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add new journey functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add new journey feature coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Start Your First Journey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneySelection(BuildContext context, JourneyTrackerViewModel model) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Medical Journeys',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: model.journeys.length,
              itemBuilder: (context, index) {
                final journey = model.journeys[index];
                final isSelected = model.selectedJourney?.id == journey.id;
                
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: JourneyCard(
                    journey: journey,
                    isSelected: isSelected,
                    onTap: () => model.selectJourney(journey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyList(BuildContext context, JourneyTrackerViewModel model) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: model.journeys.length,
      itemBuilder: (context, index) {
        final journey = model.journeys[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: JourneyCard(
            journey: journey,
            isSelected: false,
            onTap: () => model.selectJourney(journey),
          ),
        );
      },
    );
  }

  Widget _buildJourneyDetails(BuildContext context, JourneyTrackerViewModel model) {
    final journey = model.selectedJourney!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Journey Progress Card
          JourneyProgressCard(journey: journey),
          
          const SizedBox(height: 24),
          
          // Detailed Progress Tracker
          JourneyProgressTracker(
            journey: journey,
            onStageTap: (stage) {
              _showStageEditDialog(context, model, journey, stage);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Journey Timeline
          Text(
            'Treatment Stages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          
          JourneyTimeline(
            stages: journey.stages,
            onStageTap: (stage) {
              _showStageEditDialog(context, model, journey, stage);
            },
            onStatusUpdate: (stage, newStatus) {
              model.updateStageStatus(journey.id, stage.id, newStatus);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Journey Information
          _buildJourneyInfo(context, journey),
          
          const SizedBox(height: 80), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildJourneyInfo(BuildContext context, MedicalJourney journey) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: const Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Journey Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Title', journey.title),
            _buildInfoRow('Description', journey.description),
            _buildInfoRow('Started', _formatDate(journey.createdAt)),
            if (journey.completedAt != null)
              _buildInfoRow('Completed', _formatDate(journey.completedAt!)),
            _buildInfoRow('Total Stages', journey.stages.length.toString()),
            _buildInfoRow('Completed Stages', 
                journey.stages.where((s) => s.status == JourneyStatus.completed).length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStageEditDialog(
    BuildContext context,
    JourneyTrackerViewModel model,
    MedicalJourney journey,
    JourneyStage stage,
  ) {
    showDialog(
      context: context,
      builder: (context) => StageEditDialog(
        journey: journey,
        stage: stage,
        onStageUpdate: (updatedStage) {
          model.updateStage(journey.id, updatedStage);
        },
        onStageDelete: (journeyId, stageId) {
          model.deleteStage(journeyId, stageId);
        },
      ),
    );
  }

  void _showReorderDialog(
    BuildContext context,
    JourneyTrackerViewModel model,
  ) {
    if (model.selectedJourney == null) return;
    
    showDialog(
      context: context,
      builder: (context) => StageReorderDialog(
        journey: model.selectedJourney!,
        onStagesReordered: (reorderedStages) {
          model.reorderStages(model.selectedJourney!.id, reorderedStages);
        },
      ),
    );
  }

  void _showAddStageDialog(
    BuildContext context,
    JourneyTrackerViewModel model,
  ) {
    if (model.selectedJourney == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AddStageDialog(
        journey: model.selectedJourney!,
        onStageAdded: (newStage) {
          model.addNewStage(model.selectedJourney!.id, newStage);
        },
      ),
    );
  }
} 