import 'package:cloud_firestore/cloud_firestore.dart';

// Model: User Chat Info
class ChatUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'farmer' ou 'buyer'
  final String? avatar;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.isOnline = false,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'buyer',
      avatar: map['avatar'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }
}

// Model: Message
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text', 'image', 'document'
  final String? imageUrl;
  final String? documentUrl;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.imageUrl,
    this.documentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
      imageUrl: data['imageUrl'],
      documentUrl: data['documentUrl'],
    );
  }
}

// Model: Conversation
class Conversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantRoles;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final Map<String, int> unreadCount; // userId -> count

  Conversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    required this.unreadCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
    };
  }

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Conversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      participantRoles: Map<String, String>.from(
        data['participantRoles'] ?? {},
      ),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastSenderId: data['lastSenderId'] ?? '',
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  // Helper: Get other participant info
  Map<String, String> getOtherParticipant(String currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return {
      'id': otherId,
      'name': participantNames[otherId] ?? 'Usuário',
      'role': participantRoles[otherId] ?? 'buyer',
    };
  }
}
