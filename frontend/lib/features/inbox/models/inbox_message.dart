/// Type of an inbox notification matching the Figma specifications (node 1888-18306).
enum InboxMessageType {
  /// Teacher swap request sent to HOD (Figma: Property 1=teacher)
  teacherSwapRequest,

  /// Response to teacher that swap was accepted (Figma: Property 1=Accepted teacher)
  teacherSwapAccepted,

  /// Response to teacher that swap was rejected (Figma: Property 1=Rejected teacher)
  teacherSwapRejected,

  /// Student attendance issue reported to HOD/Teacher (Figma: Property 1=student)
  studentIssueReport,

  /// Response to student that issue is under review (Figma: Property 1=Review Student)
  studentIssueReview,

  /// Response to student that issue was verified and corrected (Figma: Property 1=Verified Student)
  studentIssueVerified,

  /// Response to student that issue was rejected (Figma: Property 1=Rejected student)
  studentIssueRejected,

  /// Leave request sent to HOD
  leaveRequest,

  /// Leave request approved notification
  leaveApproved,
}

/// Status of an inbox item (active, accepted, rejected, underReview).
enum InboxMessageStatus {
  none,
  pending,
  accepted,
  rejected,
  underReview,
}

/// Represents an inbox notification card.
class InboxMessage {
  final String id;
  final InboxMessageType type;
  final String senderName;
  final String subject;
  final String body;
  final bool hasActions;
  final InboxMessageStatus status;

  const InboxMessage({
    required this.id,
    required this.type,
    required this.senderName,
    required this.subject,
    required this.body,
    this.hasActions = false,
    this.status = InboxMessageStatus.none,
  });

  bool get isStudentReport => type == InboxMessageType.studentIssueReport;

  bool get isStudentAvatar =>
      type == InboxMessageType.studentIssueReport;

  InboxMessage copyWith({
    String? id,
    InboxMessageType? type,
    String? senderName,
    String? subject,
    String? body,
    bool? hasActions,
    InboxMessageStatus? status,
  }) {
    return InboxMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      senderName: senderName ?? this.senderName,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      hasActions: hasActions ?? this.hasActions,
      status: status ?? this.status,
    );
  }
}

// Fallback mock inbox messages commented out - live backend notifications are used instead.
// const List<InboxMessage> mockAdminInboxMessages = [ ... ];
// const List<InboxMessage> mockTeacherInboxMessages = [ ... ];
// const List<InboxMessage> mockStudentInboxMessages = [ ... ];