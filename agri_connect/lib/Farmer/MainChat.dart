import 'package:agri_connect/Services/FirebaseChatService.dart';
import 'package:flutter/material.dart';
import 'package:agri_connect/Services/api_service.dart';
import 'package:agri_connect/Farmer/chat.dart';
import 'package:intl/intl.dart';

class MainChat extends StatefulWidget {
  final int currentIndex;
  const MainChat({super.key, this.currentIndex = 2});

  @override
  State<MainChat> createState() => _MainChatState();
}

class _MainChatState extends State<MainChat> with WidgetsBindingObserver {
  final FirebaseChatService _chatService = FirebaseChatService();
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  Map<String, Map<String, dynamic>> _userCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    if (_currentUserId != null) {
      _chatService.updateUserPresence(_currentUserId!, false);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUserId != null) {
      if (state == AppLifecycleState.resumed) {
        _chatService.updateUserPresence(_currentUserId!, true);
      } else if (state == AppLifecycleState.paused) {
        _chatService.updateUserPresence(_currentUserId!, false);
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUserId = await _apiService.getCurrentUserId();
      print('Current User ID: $_currentUserId'); // Debug
      if (_currentUserId != null) {
        _chatService.updateUserPresence(_currentUserId!, true);
        _loadConversations();
      } else {
        print('No current user ID found'); // Debug
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading current user: $e'); // Debug
      setState(() => _isLoading = false);
    }
  }

  void _loadConversations() {
    print('Loading conversations for user: $_currentUserId'); // Debug

    _chatService
        .getConversations(_currentUserId!)
        .listen(
          (conversations) async {
            print('Received conversations: ${conversations.length}'); // Debug
            List<Map<String, dynamic>> enrichedConversations = [];

            for (var conv in conversations) {
              String otherUserId = _getOtherUserId(conv);
              print(
                'Processing conversation with other user: $otherUserId',
              ); // Debug

              // Cache de usuários
              if (!_userCache.containsKey(otherUserId)) {
                try {
                  final userDetails = await _apiService.getUserDetails(
                    otherUserId,
                  );
                  if (userDetails != null) {
                    _userCache[otherUserId] = userDetails;
                    print('Cached user details for $otherUserId'); // Debug
                  } else {
                    print('No user details for $otherUserId'); // Debug
                  }
                } catch (e) {
                  print(
                    'Error fetching user details for $otherUserId: $e',
                  ); // Debug
                }
              }

              if (_userCache.containsKey(otherUserId)) {
                final user = _userCache[otherUserId]!;
                enrichedConversations.add({
                  ...conv,
                  'otherUserId': otherUserId,
                  'name': user['name'] ?? 'Usuário',
                  'role': _getUserRole(user['user_type']),
                  'profileImage': user['profile_image_url'],
                  'location': user['location'],
                });
              }
            }

            print(
              'Enriched conversations: ${enrichedConversations.length}',
            ); // Debug
            if (mounted) {
              setState(() {
                _conversations = enrichedConversations;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            print('Error in conversations stream: $error'); // Debug
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao carregar conversas: $error')),
              );
            }
          },
          onDone: () {
            print('Conversations stream done'); // Debug
          },
        );
  }

  String _getOtherUserId(Map<String, dynamic> conversation) {
    Map participants = conversation['participants'] ?? {};
    for (String userId in participants.keys) {
      if (userId != _currentUserId) return userId;
    }
    return '';
  }

  String _getUserRole(String? userType) {
    switch (userType) {
      case 'farmer':
        return 'Agricultor';
      case 'buyer':
        return 'Comprador';
      case 'transporter':
        return 'Transportador';
      default:
        return 'Usuário';
    }
  }

  List<Map<String, dynamic>> get filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;

    return _conversations.where((conv) {
      return conv['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          conv['lastMessage'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'pt_BR').format(date);
    } else {
      return DateFormat('dd/MM').format(date);
    }
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
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF2E7D32),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
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

          // Lista de conversas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conv = filteredConversations[index];
                      return _buildChatTile(conv);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _currentUserId != null
          ? FloatingActionButton(
              onPressed: () => _showNewChatDialog(context),
              backgroundColor: const Color(0xFF25D366),
              child: const Icon(Icons.message, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhuma conversa ainda'
                : 'Nenhum resultado encontrado',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Comece uma conversa com um agricultor'
                : 'Tente pesquisar com outros termos',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> conv) {
    final unreadCount = (conv['unreadCount']?[_currentUserId] ?? 0) as int;
    final isOnline = conv['isOnline'] ?? false;

    return InkWell(
      onTap: () async {
        // Marcar como lido
        await _chatService.markMessagesAsRead(
          _currentUserId!,
          conv['otherUserId'],
        );

        // Navegar para o chat
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Chat(
                currentIndex: widget.currentIndex,
                userId: conv['otherUserId'],
                userName: conv['name'],
                userRole: conv['role'],
                isOnline: isOnline,
              ),
            ),
          );
        }
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green,
                    backgroundImage: conv['profileImage'] != null
                        ? NetworkImage(conv['profileImage'])
                        : null,
                    child: conv['profileImage'] == null
                        ? Text(
                            conv['name'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conv['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(conv['lastMessageTime']),
                          style: TextStyle(
                            fontSize: 12,
                            color: unreadCount > 0
                                ? const Color(0xFF25D366)
                                : Colors.grey[600],
                            fontWeight: unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                        conv['role'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv['lastMessage'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
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
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configurações'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FarmersListSheet(
        currentUserId: _currentUserId!,
        currentIndex: widget.currentIndex,
      ),
    );
  }
}

// Widget separado para lista de agricultores
class FarmersListSheet extends StatefulWidget {
  final String currentUserId;
  final int currentIndex;

  const FarmersListSheet({
    super.key,
    required this.currentUserId,
    required this.currentIndex,
  });

  @override
  State<FarmersListSheet> createState() => _FarmersListSheetState();
}

class _FarmersListSheetState extends State<FarmersListSheet> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _farmers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    try {
      final farmers = await _apiService.getBuyers(search: _searchQuery);
      if (mounted) {
        setState(() {
          _farmers = farmers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar compradores: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadFarmers();
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar compradores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _farmers.isEmpty
                ? const Center(child: Text('Nenhum comprador encontrado'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: _farmers.length,
                    itemBuilder: (context, index) {
                      final farmer = _farmers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          backgroundImage: farmer['profile_image_url'] != null
                              ? NetworkImage(farmer['profile_image_url'])
                              : null,
                          child: farmer['profile_image_url'] == null
                              ? Text(
                                  farmer['name'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        title: Text(farmer['name']),
                        subtitle: Text(farmer['location'] ?? 'Agricultor'),
                        trailing: farmer['rating'] != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Text('${farmer['rating']}'),
                                ],
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Chat(
                                currentIndex: widget.currentIndex,
                                userId: farmer['id'].toString(),
                                userName: farmer['name'],
                                userRole: 'Agricultor',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
