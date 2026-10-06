import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/inbox_message.dart';

class InboxRepository {
  final ApiClient _apiClient;

  InboxRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch notifications for a user from GET /api/notifications/:userId
  Future<List<InboxMessage>> getNotifications(String userId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.userNotifications(userId));
      if (response.data['success'] == true) {
        final list = response.data['notifications'] as List? ?? [];
        return list.map((item) {
          final title = item['title']?.toString() ?? 'Notification';
          final message = item['message']?.toString() ?? '';
          final id = item['_id']?.toString() ?? '';
          
          InboxMessageType type = InboxMessageType.teacherSwapAccepted;
          if (title.toLowerCase().contains('leave approved')) {
            type = InboxMessageType.leaveApproved;
          } else if (title.toLowerCase().contains('leave')) {
            type = InboxMessageType.leaveRequest;
          } else if (title.toLowerCase().contains('review')) {
            type = InboxMessageType.studentIssueReview;
          } else if (title.toLowerCase().contains('verified')) {
            type = InboxMessageType.studentIssueVerified;
          } else if (title.toLowerCase().contains('rejected')) {
            type = InboxMessageType.studentIssueRejected;
          }

          return InboxMessage(
            id: id,
            type: type,
            senderName: 'System / HOD',
            subject: title,
            body: message,
            hasActions: false,
            status: item['isRead'] == true ? InboxMessageStatus.accepted : InboxMessageStatus.none,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[InboxRepository] getNotifications error: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.dio.put(ApiEndpoints.markNotificationRead(notificationId));
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[InboxRepository] markAsRead error: $e');
      return false;
    }
  }

  /// Fetch pending leaves (for HOD / Class Teacher)
  Future<List<InboxMessage>> getPendingLeaves() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.leaves);
      if (response.data['success'] == true) {
        final list = response.data['leaves'] as List? ?? [];
        return list.map((item) {
          final id = item['_id']?.toString() ?? '';
          final reason = item['reason']?.toString() ?? 'Leave request';
          final status = item['status']?.toString() ?? 'PENDING';
          final applicantType = item['applicantType']?.toString() ?? 'Teacher';

          return InboxMessage(
            id: id,
            type: InboxMessageType.leaveRequest,
            senderName: '$applicantType Request',
            subject: 'Leave request',
            body: reason,
            hasActions: status.contains('PENDING'),
            status: status == 'APPROVED'
                ? InboxMessageStatus.accepted
                : status == 'REJECTED'
                    ? InboxMessageStatus.rejected
                    : InboxMessageStatus.pending,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[InboxRepository] getPendingLeaves error: $e');
      return [];
    }
  }

  /// Approve leave
  Future<bool> approveLeave(String leaveId) async {
    try {
      final response = await _apiClient.dio.put(ApiEndpoints.approveLeave(leaveId));
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[InboxRepository] approveLeave error: $e');
      return false;
    }
  }

  /// Reject leave
  Future<bool> rejectLeave(String leaveId) async {
    try {
      final response = await _apiClient.dio.put(ApiEndpoints.rejectLeave(leaveId));
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('[InboxRepository] rejectLeave error: $e');
      return false;
    }
  }
}
