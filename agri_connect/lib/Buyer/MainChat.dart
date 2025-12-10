import 'package:agri_connect/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:agri_connect/Farmer/chat.dart';

class MainChat extends StatefulWidget {
  final int currentIndex;
  const MainChat({super.key, this.currentIndex = 2});

  @override
  State<MainChat> createState() => _MainChatState();
}

class _MainChatState extends State<MainChat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentUserId;

  final List<Map<String, dynamic>> chats = [
    {
      'id': 1,
      'name': 'João Machado',
      'role': 'Agricultor',
      'lastMessage': 'Posso entregar sim! Onde fica seu restaurante?',
      'time': '9:43',
      'unreadCount': 2,
      'isOnline': true,
      'avatar': 'JM',
      'avatarColor': Colors.green,
    },
    {
      'id': 2,
      'name': 'Maria Santos',
      'role': 'Compradora',
      'lastMessage': 'Obrigada! Recebi os tomates hoje.',
      'time': '8:15',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'MS',
      'avatarColor': Colors.blue,
    },
    {
      'id': 3,
      'name': 'Carlos Pereira',
      'role': 'Agricultor',
      'lastMessage': 'Tenho alface fresca disponível. Quer?',
      'time': 'Ontem',
      'unreadCount': 1,
      'isOnline': true,
      'avatar': 'CP',
      'avatarColor': Colors.orange,
    },
    {
      'id': 4,
      'name': 'Ana Costa',
      'role': 'Compradora',
      'lastMessage': 'Posso passar amanhã para buscar.',
      'time': 'Ontem',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'AC',
      'avatarColor': Colors.purple,
    },
    {
      'id': 5,
      'name': 'Pedro Lopes',
      'role': 'Agricultor',
      'lastMessage': 'Sim, tenho cenouras orgânicas.',
      'time': 'Ter',
      'unreadCount': 0,
      'isOnline': true,
      'avatar': 'PL',
      'avatarColor': Colors.teal,
    },
    {
      'id': 6,
      'name': 'Beatriz Silva',
      'role': 'Compradora',
      'lastMessage': 'Quanto custa o quilo de batata?',
      'time': 'Seg',
      'unreadCount': 3,
      'isOnline': false,
      'avatar': 'BS',
      'avatarColor': Colors.pink,
    },
    {
      'id': 7,
      'name': 'Ricardo Alves',
      'role': 'Agricultor',
      'lastMessage': 'Fechado! Entrego amanhã cedo.',
      'time': 'Dom',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'RA',
      'avatarColor': Colors.indigo,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _chatService.getCurrentUserId();
    if (_currentUserId != null) {
      _chatService.updateUserPresence(_currentUserId!, true);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_currentUserId != null) {
      _chatService.updateUserPresence(_currentUserId!, false);
    }
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredChats {
    if (_searchQuery.isEmpty) {
      return chats;
    }
    return chats.where((chatItem) {
      return chatItem['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          chatItem['lastMessage'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mensagens',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Toggle search bar
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF2E7D32),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar conversas...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Chats list
          Expanded(
            child: filteredChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhuma conversa ainda'
                              : 'Nenhum resultado encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Comece uma conversa com um agricultor ou comprador'
                              : 'Tente pesquisar com outros termos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chatData = filteredChats[index];
                      return _buildChatTile(chatData);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context);
        },
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chatData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => chat(currentIndex: widget.currentIndex),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: chatData['avatarColor'],
                    child: Text(
                      chatData['avatar'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (chatData['isOnline'])
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chatData['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: chatData['unreadCount'] > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          chatData['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: chatData['unreadCount'] > 0
                                ? const Color(0xFF25D366)
                                : Colors.grey[600],
                            fontWeight: chatData['unreadCount'] > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chatData['role'],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatData['lastMessage'],
                            style: TextStyle(
                              fontSize: 14,
                              color: chatData['unreadCount'] > 0
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: chatData['unreadCount'] > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chatData['unreadCount'] > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chatData['unreadCount']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.grey),
              title: const Text('Conversas arquivadas'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversas arquivadas')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_border, color: Colors.grey),
              title: const Text('Conversas favoritas'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conversas favoritas')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.message, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nova Conversa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar contatos...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      child: Text(
                        'U${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Usuário ${index + 1}'),
                    subtitle: const Text('Agricultor'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              chat(currentIndex: widget.currentIndex),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
