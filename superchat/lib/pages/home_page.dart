import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/util/constants.dart';
import 'package:superchat/pages/sign_in_page.dart';
import 'package:superchat/widgets/stream_listener.dart';
import 'chat_page.dart';
import 'package:superchat/chat_app.dart';
import 'compte.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamListener<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      listener: (user) {
        if (user == null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
                  (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(kAppTitle),
          backgroundColor: theme.colorScheme.primary,
          actions: [
        IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // Vous pouvez ajouter des actions supplémentaires après la déconnexion si nécessaire
        },
      ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
                // Vous pouvez ajouter des actions supplémentaires après la déconnexion si nécessaire
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _collectionRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Utilise un ListView.builder pour afficher tous les utilisateurs
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // Accède aux données de chaque utilisateur
                  var userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  print("tata"+ userData.toString());
                  // Utilise ces données pour construire un widget d'élément de liste
                  return ListTile(
                    title: Text(userData['displayName'] ?? 'Nom d\'utilisateur manquant'),
                    subtitle: Text(userData['bin'] ?? 'bio manquant'),
                    onTap: () {
                      // Naviguer vers la page ChatPage en passant l'ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(userId: userData['id']),
                        ),
                      );
                    },
                  );


                },
              );
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}