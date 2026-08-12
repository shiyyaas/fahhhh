/// Type of an inbox message.
enum InboxMessageType { teacher, student, leave, swap }

/// Status of a swap request as seen by the requester.
enum InboxMessageStatus { none, pending, accepted, rejected }

/// An inbox message card. `actionable` controls whether the Accept/Reject
/// (or Review) buttons show; otherwise the status is rendered in the body.
class InboxMessage {
  final String id;
  final InboxMessageType type;
  final String senderName;
  final String subject;
  final String body;
  final bool hasAcceptAction;
  final InboxMessageStatus status;

  const InboxMessage({
    required this.id,
    required this.type,
    required this.senderName,
    required this.subject,
    required this.body,
    this.hasAcceptAction = true,
    this.status = InboxMessageStatus.none,
  });

  InboxMessage copyWith({InboxMessageStatus? status}) {
    return InboxMessage(
      id: id,
      type: type,
      senderName: senderName,
      subject: subject,
      body: body,
      hasAcceptAction: hasAcceptAction,
      status: status ?? this.status,
    );
  }
}

/// Admin inbox messages (teacher swap requests, student attendance issues).
const List<InboxMessage> mockAdminInboxMessages = [
  InboxMessage(
    id: 'msg_1',
    type: InboxMessageType.teacher,
    senderName: 'Rijina NM',
    subject: 'Swap request',
    body:
        'Rijina NM is requesting to swap 1st hour of Monday with Anju krishna in S2BCA',
  ),
  InboxMessage(
    id: 'msg_2',
    type: InboxMessageType.student,
    senderName: 'Shiyas ps',
    subject: 'Attendance issue',
    body:
        'Shiyas ps reported an Attendance  issue during 1st hour (S2BCA) today.',
    hasAcceptAction: false,
  ),
  InboxMessage(
    id: 'msg_3',
    type: InboxMessageType.leave,
    senderName: 'Sheetal miss',
    subject: 'Leave request',
    body: 'Sheetal miss requested leave for 15th August (5th hour - S4BCA).',
  ),
];

/// Teacher inbox messages (their swap request status updates from the HOD).
const List<InboxMessage> mockTeacherInboxMessages = [
  InboxMessage(
    id: 'tmsg_1',
    type: InboxMessageType.swap,
    senderName: 'Anu varghese - HOD',
    subject: 'Swap request',
    body:
        'Your request to swap 1st hour of Monday with Anju krishna in S2BCA has been Rejected. Please contact the HOD for further clarification.',
    hasAcceptAction: false,
    status: InboxMessageStatus.rejected,
  ),
  InboxMessage(
    id: 'tmsg_2',
    type: InboxMessageType.swap,
    senderName: 'Anu varghese - HOD',
    subject: 'Swap request',
    body:
        'Your request to swap 2nd hour of Tuesday with Lakshmi in S4BCA has been Accepted. Timetable has been updated accordingly.',
    hasAcceptAction: false,
    status: InboxMessageStatus.accepted,
  ),
  InboxMessage(
    id: 'tmsg_3',
    type: InboxMessageType.leave,
    senderName: 'Anu varghese - HOD',
    subject: 'Leave request',
    body: 'Your leave request for 15th August has been approved.',
    hasAcceptAction: false,
    status: InboxMessageStatus.accepted,
  ),
];