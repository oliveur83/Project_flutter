import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String displayName;
  const ChatPage({required this.userId, required this.displayName, Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('messages');
  User? user = FirebaseAuth.instance.currentUser;
  late Stream<QuerySnapshot> _usersStream;

  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersStream = getUsersStream();
  }

  Stream<QuerySnapshot> getUsersStream() {
    return _usersCollection.snapshots();
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    User? user = FirebaseAuth.instance.currentUser;
    if (messageText.isNotEmpty) {
      _usersCollection.add({
        'from': widget.userId,
        'to': user?.uid,
        'content': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        print('Message sent: $messageText');
        _messageController.clear();
      }).catchError((error) {
        print('Error sending message: $error');
        // Ajoutez ici la gestion des erreurs d'envoi du message à Firestore
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.displayName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _usersStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                var users = snapshot.data?.docs ?? [];
                print("toto" + users.toString());

                for (var user in users) {
                  print("toto");
                  print(user.data());
                }

                users = users.reversed.toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;

                    if (userData['from'] == widget.userId && userData['to'] == user?.uid) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.blue, // Remplacez Colors.green par la couleur que vous souhaitez
                            borderRadius: BorderRadius.circular(20.0), // Ajustez le rayon selon vos préférences
                          ),// Remplacez 200.0 par la largeur souhaitée
                          child: ListTile(
                           // Remplacez Colors.blue par la couleur que vous souhaitez
                            title: Text("vous"),
                            subtitle: Text(userData['content'] ?? 'bio manquant'),
                            // Autres éléments du ListTile si nécessaire
                          ),
                        ),
                      );


                    } else if (userData['to'] == widget.userId && userData['from'] == user?.uid) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.green, // Remplacez Colors.green par la couleur que vous souhaitez
                            borderRadius: BorderRadius.circular(20.0), // Ajustez le rayon selon vos préférences
                          ),// Remplacez 200.0 par la largeur souhaitée
                          child: ListTile(
                           // Remplacez Colors.blue par la couleur que vous souhaitez
                            title: Text("vous"),
                            subtitle: Text(userData['content'] ?? 'bio manquant'),
                            // Autres éléments du ListTile si nécessaire
                          ),
                        ),
                      );
                    } else {
                      // Retourner un Widget vide (Container) si le message ne provient pas de l'expéditeur ciblé
                      return Container();
                    }
                  },
                );

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
