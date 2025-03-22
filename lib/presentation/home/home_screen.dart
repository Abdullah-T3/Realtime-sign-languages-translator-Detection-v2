import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:real_time_sign_lansuage_v2/core/Responsive/ui_component/info_widget.dart';
import 'package:real_time_sign_lansuage_v2/core/theming/styles.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/services/service_locator.dart';
import '../../logic/cubits/auth/auth_cubit.dart';
import '../chat/chat_message_screen.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/chat_list_tile.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? "";

    super.initState();
  }

  void _showContactsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return const Center(child: Text("No contacts found"));
                    }
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact["name"]),
                          onTap: () {
                            getIt<AppRouter>().push(
                              ChatMessageScreen(
                                receiverId: contact['id'],
                                receiverName: contact['name'],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InfoWidget(
        builder: (context, deviceInfo) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              leading: Image.asset("assets/images/chats_Logo.png"),
              leadingWidth: deviceInfo.screenWidth * 0.2,
              title: Text(
                "Chats",
                style: TextStyles.title.copyWith(
                  fontSize: deviceInfo.screenWidth * 0.05,
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(
                    right: deviceInfo.screenWidth * 0.03,
                  ),
                  child: InkWell(
                    onTap: () async {
                      await getIt<AuthCubit>().signOut();
                      getIt<AppRouter>().pushAndRemoveUntil(
                        const LoginScreen(),
                      );
                    },
                    child: Icon(
                      Icons.logout,
                      size: deviceInfo.screenWidth * 0.07,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            body: StreamBuilder(
              stream: _chatRepository.getChatRooms(_currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text("error:${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chats = snapshot.data!;
                if (chats.isEmpty) {
                  return const Center(child: Text("No recent chats"));
                }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ChatListTile(
                      chat: chat,
                      currentUserId: _currentUserId,
                      onTap: () {
                        final otherUserId = chat.participants.firstWhere(
                          (id) => id != _currentUserId,
                        );
                        print("home screen current user id $_currentUserId");
                        final outherUserName =
                            chat.participantsName?[otherUserId] ?? "Unknown";
                        getIt<AppRouter>().push(
                          ChatMessageScreen(
                            receiverId: otherUserId,
                            receiverName: outherUserName,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showContactsList(context),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
