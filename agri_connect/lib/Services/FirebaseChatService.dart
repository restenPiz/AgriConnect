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

      debugPrint('✅ Mensagem enviada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao enviar mensagem: $e');
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
    try {
      final conversationRef = _database.child('conversations').child(chatId);

      // Primeiro, obter dados existentes
      final snapshot = await conversationRef.get();
      Map<String, dynamic> conversationData = {};

      if (snapshot.exists) {
        conversationData = Map<String, dynamic>.from(snapshot.value as Map);
      }

      // Atualizar campos
      conversationData['chatId'] = chatId;
      conversationData['lastMessage'] = message;
      conversationData['lastMessageTime'] = ServerValue.timestamp;

      // Garantir que participants existe
      if (!conversationData.containsKey('participants')) {
        conversationData['participants'] = {};
      }
      conversationData['participants'][senderId] = true;
      conversationData['participants'][receiverId] = true;

      // Atualizar contador de não lidas
      if (!conversationData.containsKey('unreadCount')) {
        conversationData['unreadCount'] = {};
      }
      conversationData['unreadCount'][receiverId] =
          (conversationData['unreadCount'][receiverId] ?? 0) + 1;

      await conversationRef.set(conversationData);
      debugPrint('✅ Última mensagem atualizada');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar última mensagem: $e');
    }
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
          if (event.snapshot.value == null) {
            debugPrint('📭 Nenhuma mensagem no chat $chatId');
            return [];
          }

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

          debugPrint('📬 ${messageList.length} mensagens carregadas');
          return messageList;
        });
  }

  // Obter conversas do usuário
  Stream<List<Map<String, dynamic>>> getConversations(String userId) {
    debugPrint('🔍 Buscando conversas para userId: $userId');

    return _database
        .child('conversations')
        .orderByChild('lastMessageTime')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            debugPrint('📭 Nenhuma conversa encontrada no Firebase');
            return [];
          }

          Map<dynamic, dynamic> conversations = event.snapshot.value as Map;
          List<Map<String, dynamic>> conversationList = [];

          conversations.forEach((key, value) {
            try {
              Map<String, dynamic> conversation = Map<String, dynamic>.from(
                value,
              );

              // Verificar se o usuário é participante
              Map<dynamic, dynamic>? participants =
                  conversation['participants'];
              if (participants != null && participants.containsKey(userId)) {
                conversation['key'] = key;
                conversationList.add(conversation);
                debugPrint('✅ Conversa $key adicionada');
              }
            } catch (e) {
              debugPrint('⚠️ Erro ao processar conversa $key: $e');
            }
          });

          // Ordenar por última mensagem (mais recente primeiro)
          conversationList.sort((a, b) {
            int timeA = a['lastMessageTime'] ?? 0;
            int timeB = b['lastMessageTime'] ?? 0;
            return timeB.compareTo(timeA);
          });

          debugPrint(
            '📬 ${conversationList.length} conversas encontradas para $userId',
          );
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
          if (value['isRead'] == false && value['senderId'] != receiverId) {
            updates['messages/$chatId/$key/isRead'] = true;
          }
        });

        if (updates.isNotEmpty) {
          await _database.update(updates);
          debugPrint('✅ ${updates.length} mensagens marcadas como lidas');
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
      debugPrint('❌ Erro ao marcar mensagens como lidas: $e');
    }
  }

  // Atualizar presença do usuário
  Future<void> updateUserPresence(String userId, bool isOnline) async {
    try {
      await _database.child('users').child(userId).update({
        'isOnline': isOnline,
        'lastSeen': ServerValue.timestamp,
      });

      debugPrint(
        '✅ Presença atualizada: $userId - ${isOnline ? "online" : "offline"}',
      );
    } catch (e) {
      debugPrint('⚠️ Erro ao atualizar presença: $e');
      // Não relançar erro para não travar o app
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
      debugPrint('✅ Conversa deletada: $chatId');
    } catch (e) {
      debugPrint('❌ Erro ao deletar conversa: $e');
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
      debugPrint('✅ Histórico limpo: $chatId');
    } catch (e) {
      debugPrint('❌ Erro ao limpar histórico: $e');
      rethrow;
    }
  }
}
