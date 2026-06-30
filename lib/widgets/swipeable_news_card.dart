import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/subscription_model.dart';

/// Swipeable news card widget for Tinder-like news browsing
class SwipeableNewsCard extends StatelessWidget {
  final GeneratedNews news;
  final VoidCallback? onTap;
  final bool showOverlay;
  final bool isLiked;
  final bool isDismissed;

  const SwipeableNewsCard({
    super.key,
    required this.news,
    this.onTap,
    this.showOverlay = false,
    this.isLiked = false,
    this.isDismissed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      news.topic.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Title
                  Text(
                    news.title,
                    style: TextStyle(
                      fontFamily: 'Newsreader',
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  
                  // Summary
                  Text(
                    news.summary.isNotEmpty ? news.summary : _truncateContent(news.content),
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  
                  // Footer info
                  Row(
                    children: [
                      // Style badge
                      _buildInfoBadge(
                        icon: Icons.style_rounded,
                        label: news.style.displayName,
                      ),
                      SizedBox(width: 8),
                      // Tone badge
                      _buildInfoBadge(
                        icon: Icons.mood_rounded,
                        label: news.tone.displayName,
                      ),
                      Spacer(),
                      // Word count
                      Text(
                        '${news.wordCount} words',
                        style: TextStyle(
                          color: AppTheme.textMuted.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Swipe hints
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.error.withValues(alpha: 0.7),
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Dismiss',
                            style: TextStyle(
                              color: AppTheme.error.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Save',
                            style: TextStyle(
                              color: AppTheme.success.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.success.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Like overlay
            if (showOverlay && isLiked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.success, width: 3),
                        ),
                      child: Text(
                        'SAVED',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Dismiss overlay
            if (showOverlay && isDismissed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.2),
                    ),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.error, width: 3),
                        ),
                      child: Text(
                        'DISMISSED',
                        style: TextStyle(
                          color: AppTheme.error,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.5),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateContent(String content) {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }
}
