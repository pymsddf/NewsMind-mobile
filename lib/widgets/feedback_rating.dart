import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/intelligence_design_system.dart';
import '../services/history_service.dart';

class FeedbackRating extends StatefulWidget {
  final String historyId;

  const FeedbackRating({super.key, required this.historyId});

  @override
  State<FeedbackRating> createState() => _FeedbackRatingState();
}

class _FeedbackRatingState extends State<FeedbackRating> {
  String? _selectedFeedback;
  bool _isSubmitting = false;

  Future<void> _submitFeedback(String feedback) async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
      _selectedFeedback = feedback;
    });

    try {
      final success = await HistoryService.submitFeedback(widget.historyId, feedback);
      if (!success) {
        // Handle failure if needed
      }
    } catch (e) {
      // Handle error if needed
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historyId.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: IntelligenceSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Was this analysis helpful?',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: IntelligenceColors.secondaryTextGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: IntelligenceSpacing.compact),
          Row(
            children: [
              _FeedbackButton(
                icon: Icons.thumb_up_alt_rounded,
                label: 'Helpful',
                isSelected: _selectedFeedback == 'like',
                onPressed: () => _submitFeedback('like'),
                selectedColor: IntelligenceColors.electricTeal,
              ),
              SizedBox(width: IntelligenceSpacing.standard),
              _FeedbackButton(
                icon: Icons.thumb_down_alt_rounded,
                label: 'Not Helpful',
                isSelected: _selectedFeedback == 'dislike',
                onPressed: () => _submitFeedback('dislike'),
                selectedColor: IntelligenceColors.crimsonSpike,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color selectedColor;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : IntelligenceColors.slateGrey;
    final bgColor = isSelected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: IntelligenceSpacing.standard,
            vertical: IntelligenceSpacing.compact,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
