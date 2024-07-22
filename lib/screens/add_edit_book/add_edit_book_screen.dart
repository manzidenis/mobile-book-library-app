import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/book.dart';
import '../../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;

  AddEditBookScreen({this.book});

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _author;
  late String _about;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _title = widget.book?.title ?? '';
    _author = widget.book?.author ?? '';
    _about = widget.book?.about ?? '';
    _image = widget.book?.imagePath != null ? XFile(widget.book!.imagePath!) : null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book == null ? 'Add Book' : 'Edit Book',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [Colors.grey[800]!, Colors.grey[700]!]
                          : [Colors.grey[300]!, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(File(_image!.path), fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: isDarkMode ? Colors.white : Colors.grey[600]),
                      Text(
                        'Tap to pick an image',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8.0),
                ),
              ),
              SizedBox(height: 20),
              _buildTextFormField(
                context,
                initialValue: _title,
                labelText: 'Title',
                onSaved: (value) => _title = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextFormField(
                context,
                initialValue: _author,
                labelText: 'Author',
                onSaved: (value) => _author = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextFormField(
                context,
                initialValue: _about,
                labelText: 'About',
                maxLines: 3,
                onSaved: (value) => _about = value ?? '',
                validator: (value) {
                  if (value != null) {
                    final wordCount = value.split(RegExp(r'\s+')).length;
                    if (wordCount > 20) {
                      return 'Please enter no more than 20 words.';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black26,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      BuildContext context, {
        required String initialValue,
        required String labelText,
        required FormFieldSetter<String> onSaved,
        required FormFieldValidator<String> validator,
        int maxLines = 1,
      }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final book = Book(
        id: widget.book?.id,
        title: _title,
        author: _author,
        rating: widget.book?.rating ?? 0,
        isRead: widget.book?.isRead ?? false,
        about: _about,
        imagePath: _image?.path,
      );
      if (widget.book == null) {
        Provider.of<BookProvider>(context, listen: false).addBook(book);
      } else {
        Provider.of<BookProvider>(context, listen: false).updateBook(book);
      }
      Navigator.of(context).pop();
    }
  }
}
