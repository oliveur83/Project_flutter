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
                stream: _collectionRef.where('id', isEqualTo: user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var userDocuments = snapshot.data!.docs;
                    if (userDocuments.isNotEmpty) {
                      var userData = userDocuments.first.data() as Map<String, dynamic>;

                      return ListView.builder(
                        itemCount: 1, // Vous n'affichez qu'un seul élément puisque vous accédez à un seul document
                        itemBuilder: (context, index) {
                          print("titi" + userData.toString());
                          return ListTile(
                            title: Text(
                              userData['displayName'] ?? 'Nom d\'utilisateur manquant',
                            ),
                            subtitle: Text(userData['bio'] ?? 'pas de bin '),

                          );
                        },
                      );
                    } else {
                      // L'utilisateur n'a pas de document correspondant à son ID
                      return Text('Aucun document trouvé pour cet utilisateur.');
                    }
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
                    onPressed: () async {
                      String newDisplayName = displayNameController.text;
                      String newBin = binController.text;
                      print(user.toString()+"titi");
                      if (user?.uid != null) {
                        String targetId = user!.uid; // ou la valeur de l'id que vous souhaitez mettre à jour

// Effectuez une requête pour obtenir le document avec le champ 'id' égal à targetId
                        var querySnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('id', isEqualTo: targetId)
                            .get();

// Vérifiez si un document correspondant a été trouvé
                        if (querySnapshot.docs.isNotEmpty) {
                          // Récupérez le premier document trouvé
                          var userDocument = querySnapshot.docs.first;

                          // Mettez à jour le document avec les nouvelles valeurs
                          await userDocument.reference.update({
                            'displayName': newDisplayName,
                            'bio': newBin,
                          });

                          print('Document mis à jour avec succès.');
                        } else {
                          // Aucun document correspondant n'a été trouvé
                          print('Aucun document trouvé avec l\'ID spécifié.');
                        }
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
