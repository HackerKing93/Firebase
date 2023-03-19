import 'package:firebase/ui/auth/login_screen.dart';
import 'package:firebase/ui/auth/posts/add_posts.dart';
import 'package:firebase/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../../../widgets/round_button.dart';
import '../../upload_image.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Test');
  final searchFilter = TextEditingController();
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Post'),
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

          //Second methos to fetch data from database
          // Expanded(
          //     child: StreamBuilder(
          //   stream: ref.onValue,
          //   builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          //     if (!snapshot.hasData) {
          //       return CircularProgressIndicator();
          //     } else {
          //       Map<dynamic, dynamic> map =
          //           snapshot.data!.snapshot.value as dynamic;
          //       List<dynamic> list = [];
          //       list.clear();
          //       list = map.values.toList();

          //       return ListView.builder(
          //           itemCount: snapshot.data!.snapshot.children.length,
          //           itemBuilder: (context, index) {
          //             return ListTile(
          //               title: Text(list[index]['Name']),
          //               subtitle: Text(list[index]['id']),
          //             );
          //           });
          //     }
          //   },
          // )),
          //first method to fetch data from database
          Expanded(
            child: FirebaseAnimatedList(
              query: ref,
              defaultChild: Text('Data Base is Empty'),
              itemBuilder: (context, snapshot, animation, index) {
                //for Filter
                final title = snapshot.child('Name').value.toString();

                if (searchFilter.text.isEmpty) {
                  return ListTile(
                      title: Text(snapshot.child('Name').value.toString()),
                      subtitle: Text(snapshot.child('id').value.toString()),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: 1,
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  showMyDialog(title,
                                      snapshot.child('id').value.toString());
                                },
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              )),
                          PopupMenuItem(
                              value: 1,
                              child: ListTile(
                                onTap: () {
                                  ref
                                      .child(
                                          snapshot.child('id').value.toString())
                                      .remove();
                                  Navigator.pop(context);
                                },
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              )),
                        ],
                      ));
                } else if (title
                    .toLowerCase()
                    .contains(searchFilter.text.toLowerCase().toString())) {
                  return ListTile(
                    title: Text(snapshot.child('Name').value.toString()),
                    subtitle: Text(snapshot.child('id').value.toString()),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 95),
            child: RoundButton(
                title: 'Uploade Image',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadImageScreen()));
                }),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddPostsScreen()));
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
                    ref.child(id).update(
                        {'Name': editController.text.toString()}).then((value) {
                      Utils().toastMessage('Post Updated');
                    }).onError((error, stackTrace) {
                      Utils().toastMessage(error.toString());
                    });
                  },
                  child: Text('Update'))
            ],
          );
        });
  }
}
