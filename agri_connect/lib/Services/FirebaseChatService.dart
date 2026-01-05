import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Gerar ID único para conversa entre dois usuários
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Enviar mensagem
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    String? messageType = 'text',
  }) async {
    try {
      String chatId = getChatId(senderId, receiverId);
      String messageId = _database.child('messages').child(chatId).push().key!;

      final messageData = {
        'id': messageId,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'messageType': messageType,
        'timestamp': ServerValue.timestamp,
        'isRead': false,
      };

      // Salvar mensagem
      await _database
          .child('messages')
          .child(chatId)
          .child(messageId)
          .set(messageData);

      // Atualizar última mensagem na conversa
      await _updateLastMessage(chatId, senderId, receiverId, message);

      debugPrint('Mensagem enviada com sucesso');
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      rethrow;
    }
  }

  // Atualizar última mensagem
  Future<void> _updateLastMessage(
    String chatId,
    String senderId,
    String receiverId,
    String message,
  ) async {
    final conversationData = {
      'chatId': chatId,
      'lastMessage': message,
      'lastMessageTime': ServerValue.timestamp,
      'participants': {senderId: true, receiverId: true},
      'unreadCount': {receiverId: ServerValue.increment(1)},
    };

    await _database
        .child('conversations')
        .child(chatId)
        .update(conversationData);
  }

  // Obter mensagens da conversa
  Stream<List<Map<String, dynamic>>> getMessages(
    String senderId,
    String receiverId,
  ) {
    String chatId = getChatId(senderId, receiverId);

    return _database
        .child('messages')
        .child(chatId)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return [];

          Map<dynamic, dynamic> messages = event.snapshot.value as Map;
          List<Map<String, dynamic>> messageList = [];

          messages.forEach((key, value) {
            Map<String, dynamic> message = Map<String, dynamic>.from(value);
            message['key'] = key;
            messageList.add(message);
          });

          // Ordenar por timestamp
          messageList.sort(
            (a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0),
          );

          return messageList;
        });
  }

  // Obter conversas do usuário
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    return _database
        .child('conversations')
        .orderByChild('participants/$userId')
        .equalTo(true)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return [];

          Map<dynamic, dynamic> conversations = event.snapshot.value as Map;
          List<Map<String, dynamic>> conversationList = [];

          conversations.forEach((key, value) {
            Map<String, dynamic> conversation = Map<String, dynamic>.from(
              value,
            );
            conversation['key'] = key;
            conversationList.add(conversation);
          });

          // Ordenar por última mensagem
          conversationList.sort((a, b) {
            int timeA = a['lastMessageTime'] ?? 0;
            int timeB = b['lastMessageTime'] ?? 0;
            return timeB.compareTo(timeA);
          });

          return conversationList;
        });
  }

  // Marcar mensagens como lidas
  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      String chatId = getChatId(senderId, receiverId);

      final snapshot = await _database
          .child('messages')
          .child(chatId)
          .orderByChild('receiverId')
          .equalTo(receiverId)
          .get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> messages = snapshot.value as Map;
        Map<String, dynamic> updates = {};

        messages.forEach((key, value) {
          if (value['isRead'] == false) {
            updates['messages/$chatId/$key/isRead'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await _database.update(updates);
        }

        // Resetar contador de não lidas
        await _database
            .child('conversations')
            .child(chatId)
            .child('unreadCount')
            .child(receiverId)
            .set(0);
      }
    } catch (e) {
      debugPrint('Erro ao marcar mensagens como lidas: $e');
    }
  }

  // Atualizar presença do usuário
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      await _database.child('users').child(userId).update({
        'isOnline': isOnline,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar presença: $e');
    }
  }

  // Obter status online do usuário
  Stream<bool> getUserOnlineStatus(String userId) {
    return _database
        .child('users')
        .child(userId)
        .child('isOnline')
        .onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  // Deletar conversa
  Future<void> deleteConversation(String chatId) async {
    try {
      await _database.child('messages').child(chatId).remove();
      await _database.child('conversations').child(chatId).remove();
    } catch (e) {
      debugPrint('Erro ao deletar conversa: $e');
      rethrow;
    }
  }

  // Limpar histórico de mensagens
  Future<void> clearChatHistory(String senderId, String receiverId) async {
    try {
      String chatId = getChatId(senderId, receiverId);
      await _database.child('messages').child(chatId).remove();
      await _database.child('conversations').child(chatId).update({
        'lastMessage': 'Conversa limpa',
        'lastMessageTime': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Erro ao limpar histórico: $e');
      rethrow;
    }
  }
}
