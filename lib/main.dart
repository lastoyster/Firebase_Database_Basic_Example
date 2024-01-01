import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Note {
  String id;
  String content;
  String createdOn;

  Note(this.content) {
    this.createdOn = DateTime.now().toString();
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final notesRef = FirebaseDatabase.instance.reference().child('notes');
  final inputController = TextEditingController();
  late StreamSubscription<Event> _noteAddedStream;
  List<Note> items = [];

  @override
  void initState() {
    super.initState();
    _noteAddedStream = notesRef.orderByChild("created_on").onChildAdded.listen(_onNoteAdded);
  }

  void _addNote() {
    var note = Note(inputController.text);
    inputController.text = "";
    if (note.content.isNotEmpty) {
      notesRef.push().set({
        'content': note.content,
        'created_on': note.createdOn,
      });
    }
  }

  void _onNoteAdded(Event event) {
    setState(() {
      var note = Note(event.snapshot.value["content"]);
      note.id = event.snapshot.key!;
      note.createdOn = event.snapshot.value["created_on"];
      items.add(note);
    });
  }

  void _deleteNote(int position) {
    String id = items[position].id;
    notesRef.child(id).remove().then((_) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  @override
  void dispose() {
    _noteAddedStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Using Firebase DB"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                style: TextStyle(fontSize: 24.0, height: 2.0, color: Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add a note',
                ),
                controller: inputController,
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.all(10.0),
                  itemBuilder: (context, position) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.note),
                        title: Text(items[position].content),
                        onLongPress: () {
                          _deleteNote(position);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }
}
