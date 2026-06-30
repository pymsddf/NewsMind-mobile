import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/intelligence_design_system.dart';
import '../services/notification_service.dart';
import '../widgets/newsmind_brand_title.dart';
import '../utils/error_text.dart';

/// Notifications Screen - Alert Hierarchy
/// 
/// Visual: AppBar title: 'NOTIFICATIONS'. Clean list view.
/// Cards are detailed text blocks with Mono timestamp and Noto Serif headline.
/// Correct metadata (date, time) in JetBrains Mono. Source logos are text.
/// 
/// Color-coded left-border indicators:
///   - Crimson Spike for Fact Alert
///   - Kinetics Orange for Bias Alert
/// Simple white dot unread indicator.
/// Empty state: simple centered text 'NO ALERTS'
class NotificationScreen extends StatefulWidget {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await NotificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              friendlyError(e),
              style: AppTheme.textTheme.labelMedium?.copyWith(),
            ),
            backgroundColor: IntelligenceColors.crimsonSpike,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);
      _fetchNotifications();
    } catch (e) {
      // Handle error quietly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IntelligenceColors.obsidianBlack,
      appBar: AppBar(
        backgroundColor: IntelligenceColors.obsidianBlack,
        elevation: 0,
        title: NewsMindBrandTitle(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: IntelligenceColors.secondaryTextGrey,
              size: IntelligenceSpacing.iconMd,
            ),
            onPressed: _fetchNotifications,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: IntelligenceColors.slateGrey,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: IntelligenceColors.electricTeal,
              ),
            )
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'NO ALERTS',
        style: AppTheme.textTheme.labelMedium?.copyWith(
          fontSize: IntelligenceTypography.headingMd,
          color: IntelligenceColors.secondaryTextGrey,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: EdgeInsets.all(IntelligenceSpacing.standard),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        // Backend returns `isRead`; tolerate legacy `read` too.
        final isRead = notification['isRead'] ?? notification['read'] ?? false;
        final type = notification['type'] ?? 'default';
        
        final dateStr = notification['createdAt'] ?? '';
        String formattedDate = '';
        if (dateStr.isNotEmpty) {
          try {
            final date = DateTime.parse(dateStr);
            formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
          } catch (_) {}
        }

        return _buildNotificationItem(
          type: type,
          title: notification['title'] ?? 'Notification',
          message: notification['message'] ?? '',
          dateTime: formattedDate,
          isRead: isRead,
          onTap: isRead ? null : () => _markAsRead(notification['_id']),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String type,
    required String title,
    required String message,
    required String dateTime,
    required bool isRead,
    VoidCallback? onTap,
  }) {
    final borderColor = _getAlertColor(type);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: IntelligenceSpacing.standard),
        decoration: BoxDecoration(
          color: IntelligenceColors.surfaceDark,
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(IntelligenceSpacing.standard),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(
                    right: IntelligenceSpacing.compact,
                    top: 6,
                  ),
                  color: IntelligenceColors.pureWhite,
                ),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timestamp - JetBrains Mono
                    Text(
                      dateTime,
                      style: AppTheme.textTheme.labelMedium?.copyWith(
                        fontSize: IntelligenceTypography.monoSm,
                        color: IntelligenceColors.secondaryTextGrey,
                      ),
                    ),
                    SizedBox(height: IntelligenceSpacing.compact),
                    
                    // Title - Noto Serif
                    Text(
                      title,
                      style: AppTheme.textTheme.bodyLarge?.copyWith(
                        fontSize: IntelligenceTypography.bodyMd,
                        fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                        color: IntelligenceColors.pureWhite,
                      ),
                    ),
                    
                    // Message
                    if (message.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: IntelligenceTypography.bodySm,
                          color: IntelligenceColors.secondaryTextGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'fact':
      case 'verification':
        return IntelligenceColors.crimsonSpike;
      case 'bias':
        return IntelligenceColors.kineticsOrange;
      case 'news':
      case 'generation':
        return IntelligenceColors.cyberBlue;
      default:
        return IntelligenceColors.electricTeal;
    }
  }
}
