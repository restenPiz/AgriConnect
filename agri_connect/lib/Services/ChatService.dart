import 'package:agri_connect/Models/chat_models..dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID from SharedPreferences
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    return userId?.toString();
  }

  // Get current user info from SharedPreferences
  Future<Map<String, String>> getCurrentUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('user_id')?.toString() ?? '',
      'name': prefs.getString('user_name') ?? 'Usuário',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_type') ?? 'buyer',
    };
  }

  // ==================== USER PRESENCE ====================

  /// Update user online status
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    await _firestore.collection('users').doc(userId).set({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream user online status
  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['isOnline'] ?? false);
  }

  // ==================== CONVERSATIONS ====================

  /// Get or create conversation between two users
  Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
    String otherUserName,
    String otherUserRole,
  ) async {
    final currentUserInfo = await getCurrentUserInfo();

    // Check if conversation already exists
    final existingConversation = await _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (var doc in existingConversation.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participantIds']);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new conversation
    final conversationRef = await _firestore.collection('conversations').add({
      'participantIds': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: currentUserInfo['name'],
        otherUserId: otherUserName,
      },
      'participantRoles': {
        currentUserId: currentUserInfo['role'],
        otherUserId: otherUserRole,
      },
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': '',
      'unreadCount': {currentUserId: 0, otherUserId: 0},
      'createdAt': FieldValue.serverTimestamp(),
    });

    return conversationRef.id;
  }

  /// Get all conversations for current user
  Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Conversation.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== MESSAGES ====================

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
    String? imageUrl,
  }) async {
    final currentUserInfo = await getCurrentUserInfo();
    final currentUserId = currentUserInfo['id']!;

    // Add message to messages collection
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
          'conversationId': conversationId,
          'senderId': currentUserId,
          'senderName': currentUserInfo['name'],
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': type,
          'imageUrl': imageUrl,
        });

    // Update conversation's last message
    final conversationDoc = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .get();

    final conversationData = conversationDoc.data()!;
    final participantIds = List<String>.from(
      conversationData['participantIds'],
    );
    final otherUserId = participantIds.firstWhere((id) => id != currentUserId);

    Map<String, int> unreadCount = Map<String, int>.from(
      conversationData['unreadCount'] ?? {},
    );
    unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1;

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': currentUserId,
      'unreadCount': unreadCount,
    });
  }

  /// Get messages stream
  Stream<List<Message>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String currentUserId,
  ) async {
    // Get unread messages
    final unreadMessages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    // Mark as read
    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // Reset unread count
    await _firestore.collection('conversations').doc(conversationId).update({
      'unreadCount.$currentUserId': 0,
    });
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages
    final messages = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete conversation
    await _firestore.collection('conversations').doc(conversationId).delete();
  }

  /// Get total unread messages count
  Stream<int> getTotalUnreadCount(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final unreadCount = Map<String, int>.from(
              data['unreadCount'] ?? {},
            );
            total += unreadCount[userId] ?? 0;
          }
          return total;
        });
  }

  // ==================== TYPING INDICATOR ====================

  /// Set typing status
  Future<void> setTypingStatus(
    String conversationId,
    String userId,
    bool isTyping,
  ) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing')
        .doc(userId)
        .set({'isTyping': isTyping, 'timestamp': FieldValue.serverTimestamp()});
  }

  /// Listen to typing status
  Stream<bool> getTypingStatus(String conversationId, String otherUserId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('typing')
        .doc(otherUserId)
        .snapshots()
        .map((doc) => doc.data()?['isTyping'] ?? false);
  }
}
