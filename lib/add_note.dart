import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';

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
      floatingActionButton: _hasChanges
          ? FloatingActionButton(
              onPressed: _saveNote,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }
}
