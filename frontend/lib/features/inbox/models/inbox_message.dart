/// Type of an inbox message (admin inbox).
enum InboxMessageType { teacher, student, leave }

/// An inbox message card (teacher swap request / student attendance issue / leave).
class InboxMessage {
  final String id;
  final InboxMessageType type;
  final String senderName;
  final String subject; // prominent line under the sender name
  final String body;
  final bool hasAcceptAction; // Accept (teacher) vs Review (student)

  const InboxMessage({
    required this.id,
    required this.type,
    required this.senderName,
    required this.subject,
    required this.body,
    this.hasAcceptAction = true,
  });
}

/// Mock inbox messages (replaced by repository data once backend is wired).
const List<InboxMessage> mockInboxMessages = [
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
  ),
  InboxMessage(
    id: 'msg_3',
    type: InboxMessageType.leave,
    senderName: 'Sheetal miss',
    subject: 'Leave request',
    body: 'Sheetal miss requested leave for 15th August (5th hour - S4BCA).',
  ),
];