import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/theme/app_theme.dart';

class ApartmentStatusNotification extends ConsumerWidget {
  final String status;
  final String? rejectionReason;

  const ApartmentStatusNotification({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSubtextColor(isDarkMode),
                  ),
                ),
                if (rejectionReason != null && rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reason: $rejectionReason',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'pending':
        return 'Pending Admin Approval';
      case 'approved':
        return 'Apartment Approved';
      case 'rejected':
        return 'Apartment Rejected';
      default:
        return 'Status Unknown';
    }
  }

  String _getStatusMessage() {
    switch (status) {
      case 'pending':
        return 'Your apartment is under review by our admin team. You will be notified once it\'s approved.';
      case 'approved':
        return 'Congratulations! Your apartment has been approved and is now visible to tenants.';
      case 'rejected':
        return 'Your apartment submission was rejected. Please review the reason and resubmit.';
      default:
        return 'Please contact support for more information.';
    }
  }
}