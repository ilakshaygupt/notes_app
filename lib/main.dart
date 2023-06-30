import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final noteList = prefs.getStringList('notes');
    if (noteList != null) {
      setState(() {
        notes =
            noteList.map((noteString) => Note.fromString(noteString)).toList();
      });
    }
  }

  void saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final noteList = notes.map((note) => note.toString()).toList();
    await prefs.setStringList('notes', noteList);
  }

  void addNote() async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    if (newNote != null) {
      setState(() {
        notes.add(newNote);
        saveNotes();
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
        saveNotes();
      });
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      saveNotes();
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      notes[index].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      notes[index].body,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
  late final String title;
  late final String body;

  Note({
    required this.title,
    required this.body,
  });

  Note.fromString(String noteString) {
    final parts = noteString.split('\n');
    title = parts[0];
    body = parts.sublist(1).join('\n');
  }

  @override
  String toString() {
    return '$title\n$body';
  }
}

class AddNotePage extends StatefulWidget {
  final Note? note;

  const AddNotePage({Key? key, this.note}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _bodyController = TextEditingController(text: widget.note?.body);

    _titleController.addListener(_textChanged);
    _bodyController.addListener(_textChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _textChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  void _saveNote() {
    final updatedTitle = _titleController.text;
    final updatedBody = _bodyController.text;
    if (updatedTitle.isNotEmpty && updatedBody.isNotEmpty) {
      final updatedNote = Note(
        title: updatedTitle,
        body: updatedBody,
      );
      Navigator.pop(context, updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _saveNote();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                onChanged: (_) => _textChanged(),
                decoration: const InputDecoration(
                    labelText: 'Title', border: InputBorder.none),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _bodyController,
                onChanged: (_) => _textChanged(),
                decoration: const InputDecoration(
                    labelText: 'Body', border: InputBorder.none),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
