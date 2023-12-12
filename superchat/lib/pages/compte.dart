import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superchat/pages/sign_in_page.dart';

import '../util/constants.dart';
import '../widgets/stream_listener.dart';
import 'chat_page.dart';

class AccountPage extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference _collectionRef =
  FirebaseFirestore.instance.collection('users');

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController binController = TextEditingController();

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
          ],
        ),
        body: Column(
          children: [
            // Zone pour afficher la liste existante
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _collectionRef
                    .where('id', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var userData =
                        snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        print("tata" + userData.toString());
                        return ListTile(
                          title: Text(
                              userData['displayName'] ?? 'Nom d\'utilisateur manquant'),
                          subtitle: Text(userData['bin'] ?? 'pas de bin '),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(userId: userData['id']),
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
            // Zone pour les nouveaux champs et le bouton
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau DisplayName',
                    ),
                  ),

                  TextFormField(
                    controller: binController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau Bin',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String newDisplayName = displayNameController.text;
                      String newBin = binController.text;
                      print(user.toString()+"titi");
                      if (user?.uid != null) {
                        // Utilisez la méthode set avec l'option merge pour créer ou mettre à jour le document
                        _collectionRef.doc(user?.uid).set({
                          'displayName': newDisplayName,
                          'bin': newBin,
                        }, SetOptions(merge: true)).then((_) {
                          print('Données mises à jour avec succès');
                        }).catchError((error) {
                          print('Erreur lors de la mise à jour des données : $error');
                        });
                      }
                      displayNameController.clear();
                      binController.clear();
                    },
                    child: Text('Valider'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
