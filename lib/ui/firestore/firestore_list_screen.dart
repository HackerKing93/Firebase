import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/ui/firestore/add_firestore_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../auth/login_screen.dart';
import '../auth/posts/add_posts.dart';

class FireStoreListScreen extends StatefulWidget {
  const FireStoreListScreen({super.key});

  @override
  State<FireStoreListScreen> createState() => _FireStoreListScreenState();
}

class _FireStoreListScreenState extends State<FireStoreListScreen> {
  final auth = FirebaseAuth.instance;

  final searchFilter = TextEditingController();
  final editController = TextEditingController();

  final fireStore = FirebaseFirestore.instance.collection('users').snapshots();

  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Fire Store'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                auth.signOut().then((value) {
                  Utils().toastMessage(
                    "LOGOUT Sucessfully",
                  );
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => LoginScreen())));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
              icon: const Icon(Icons.logout)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          SizedBox(
            height: 15,
          ),
          //Filter list code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: searchFilter,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              onChanged: (String value) {
                setState(() {});
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: fireStore,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Somthing went wrong');
                }
                return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              ref
                                  .doc(snapshot.data!.docs[index]['id']
                                      .toString())
                                  .update({
                                'Name': 'Hello Aayush Acharya'
                              }).then((value) {
                                Utils().toastMessage('Updated Sucessfully');
                              }).onError((error, stackTrace) {
                                Utils().toastMessage(error.toString());
                              });
                              //Delete from database
                              // ref
                              //     .doc(snapshot.data!.docs[index]['id']
                              //         .toString())
                              //     .delete();
                            },
                            title: Text(
                                snapshot.data!.docs[index]['Name'].toString()),
                            subtitle: Text(
                                snapshot.data!.docs[index]['id'].toString()),
                          );
                        }));
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddFirestore()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    editController.text = title;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update'),
            content: Container(
              child: TextField(
                controller: editController,
                decoration: InputDecoration(
                    hintText: 'Edit Here',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancle')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Update'))
            ],
          );
        });
  }
}
