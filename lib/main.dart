import 'package:flutter/material.dart';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({Key? key}) : super(key: key);

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Note> notes = [];

  void addNote() async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    if (newNote != null) {
      setState(() {
        notes.add(newNote);
      });
    }
  }

  void editNote(int index) async {
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotePage(note: notes[index]),
      ),
    );
    if (updatedNote != null) {
      setState(() {
        notes[index] = updatedNote;
      });
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: notes.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => editNote(index),
            child: Card(
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notes[index].title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      notes[index].body,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteNote(index),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Note {
  final String title;
  final String body;

  Note({required this.title, required this.body});
}

class AddNotePage extends StatefulWidget {
  final Note? note;

  const AddNotePage({Key? key, this.note}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.body;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Edit Note' : 'Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final updatedTitle = _titleController.text;
                final updatedBody = _bodyController.text;
                if (updatedTitle.isNotEmpty && updatedBody.isNotEmpty) {
                  final updatedNote = Note(
                    title: updatedTitle,
                    body: updatedBody,
                  );
                  Navigator.pop(context, updatedNote);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
