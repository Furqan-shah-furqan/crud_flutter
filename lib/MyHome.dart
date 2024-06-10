import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter/services/firestore.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textcontroller = TextEditingController();

  void opennote({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textcontroller,
        ),
        actions: [
          Center(
            child: ElevatedButton(
                onPressed: () {
                  if (docId == null) {
                    firestoreService.addNote(textcontroller.text);
                  }
                  //  update an existing note
                  else {
                    firestoreService.updateNote(docId, textcontroller.text);
                  }

                  // clear the text controller
                  textcontroller.clear();

                  // close the box
                  Navigator.pop(context);
                },
                child: Text('ADD')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('C R U D'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          opennote();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNoteStream(),
        builder: (context, snapshot) {
          //  if we have data get all the docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display a Listview
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //  get each indivisual doc
                DocumentSnapshot document = notesList[index];
                String docId = document.id;

                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as list tile
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.grey[200],
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Update
                        IconButton(
                            color: Colors.blue,
                            onPressed: () => opennote(docId: docId),
                            icon: Icon(Icons.edit_rounded)),

                        // Delete
                        IconButton(
                            color: Colors.red,
                            onPressed: () => firestoreService.deleteNote(docId),
                            icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Text('no notes..');
          }
        },
      ),
    );
  }
}
