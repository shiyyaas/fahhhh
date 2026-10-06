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

/// Admin/HOD inbox messages (teacher swap requests, student attendance issues, leave requests).
/// All sentences and structures exactly match Figma node 1888-18306.
const List<InboxMessage> mockAdminInboxMessages = [
  // Figma node 1836:13343: Property 1=teacher
  InboxMessage(
    id: 'admin_msg_1',
    type: InboxMessageType.teacherSwapRequest,
    senderName: 'Rijina NM',
    subject: 'Swap request',
    body:
        'Rijina NM is requesting to swap 1st hour of Monday with Anju krishna in S2BCA',
    hasActions: true,
    status: InboxMessageStatus.pending,
  ),
  // Figma node 1836:14146: Property 1=student
  InboxMessage(
    id: 'admin_msg_2',
    type: InboxMessageType.studentIssueReport,
    senderName: 'Shiyas ps',
    subject: 'Attendance issue',
    body:
        'Shiyas ps reported an Attendance issue during 1st hour (S2BCA) today.',
    hasActions: true,
    status: InboxMessageStatus.pending,
  ),
  // Leave request
  InboxMessage(
    id: 'admin_msg_3',
    type: InboxMessageType.leaveRequest,
    senderName: 'Sheetal miss',
    subject: 'Leave request',
    body: 'Sheetal miss requested leave for 15th August (5th hour - S4BCA).',
    hasActions: true,
    status: InboxMessageStatus.pending,
  ),
];

/// Teacher inbox messages (swap request responses from HOD, leave notifications).
/// All sentences and structures exactly match Figma node 1888-18306.
const List<InboxMessage> mockTeacherInboxMessages = [
  // Figma node 1888:18307: Property 1=Accepted teacher
  InboxMessage(
    id: 'teacher_msg_1',
    type: InboxMessageType.teacherSwapAccepted,
    senderName: 'Anu varghese - HOD',
    subject: 'Swap request',
    body:
        'Your request to swap 1st hour of Monday with Anju krishna in S2BCA has been Accepted. Timetable has been updated accordingly.',
    hasActions: false,
    status: InboxMessageStatus.accepted,
  ),
  // Figma node 1888:18324: Property 1=Rejected teacher
  InboxMessage(
    id: 'teacher_msg_2',
    type: InboxMessageType.teacherSwapRejected,
    senderName: 'Anu varghese - HOD',
    subject: 'Swap request',
    body:
        'Your request to swap 1st hour of Monday with Anju krishna in S2BCA has been Rejected. Please contact the HOD for further clarification.',
    hasActions: false,
    status: InboxMessageStatus.rejected,
  ),
  // Leave approved notification
  InboxMessage(
    id: 'teacher_msg_3',
    type: InboxMessageType.leaveApproved,
    senderName: 'Anu varghese - HOD',
    subject: 'Leave request',
    body: 'Your leave request for 15th August has been approved.',
    hasActions: false,
    status: InboxMessageStatus.accepted,
  ),
];

/// Student inbox messages (attendance issue responses from HOD).
/// All sentences and structures exactly match Figma node 1888-18306.
const List<InboxMessage> mockStudentInboxMessages = [
  // Figma node 1891:18938: Property 1=Review Student
  InboxMessage(
    id: 'student_msg_1',
    type: InboxMessageType.studentIssueReview,
    senderName: 'Anu varghese - HOD',
    subject: 'Attendance issue',
    body:
        'Your attendance issue for the 1st hour (S2BCA) has been received and is currently being reviewed. We will get back to you shortly.',
    hasActions: false,
    status: InboxMessageStatus.underReview,
  ),
  // Figma node 1891:18950: Property 1=Verified Student
  InboxMessage(
    id: 'student_msg_2',
    type: InboxMessageType.studentIssueVerified,
    senderName: 'Anu varghese - HOD',
    subject: 'Attendance issue',
    body:
        'Your attendance issue for the 1st hour (S2BCA) has been Verified and Corrected . Your attendance record has been updated accordingly.',
    hasActions: false,
    status: InboxMessageStatus.accepted,
  ),
  // Figma node 1891:18956: Property 1=Rejected student
  InboxMessage(
    id: 'student_msg_3',
    type: InboxMessageType.studentIssueRejected,
    senderName: 'Anu varghese - HOD',
    subject: 'Attendance issue',
    body:
        'Your attendance issue for the 1st hour (S2BCA) has been Rejected. Please contact the HOD directly if you have further concerns.',
    hasActions: false,
    status: InboxMessageStatus.rejected,
  ),
];