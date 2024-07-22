import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../add_edit_book/add_edit_book_screen.dart';
import 'dart:io';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  BookDetailScreen({required this.book});

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late double _currentRating;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.book.rating;
    _isRead = widget.book.isRead;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditBookScreen(book: widget.book),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: widget.book.imagePath != null &&
                      widget.book.imagePath!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.file(
                      File(widget.book.imagePath!),
                      width: 150,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            size: 150, color: Colors.red);
                      },
                    ),
                  )
                      : Icon(
                    Icons.image_not_supported,
                    size: 150,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildDetailSection(
                context,
                title: 'Author',
                content: _truncateText(widget.book.author),
              ),
              _buildDetailSection(
                context,
                title: 'About',
                content: _truncateText(widget.book.about),
              ),
              _buildRatingSection(),
              _buildStatusSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context,
      {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          'Rating (Rate the book from 1 to 5)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _currentRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _currentRating = (index + 1).toDouble();
                  Provider.of<BookProvider>(context, listen: false)
                      .updateBookRating(widget.book.id!, _currentRating);
                });
              },
            );
          }),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Text(
          'Status',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              _isRead ? 'Read' : 'Unread',
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),
            Switch(
              value: _isRead,
              onChanged: (value) {
                setState(() {
                  _isRead = value;
                  Provider.of<BookProvider>(context, listen: false)
                      .updateBookStatus(widget.book.id!, _isRead);
                });
              },
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Book'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Provider.of<BookProvider>(context, listen: false)
                    .deleteBook(widget.book.id!);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _truncateText(String? text) {
    if (text == null || text.isEmpty) {
      return 'No description available.';
    }
    List<String> words = text.split(' ');
    if (words.length <= 20) {
      return text;
    }
    return words.sublist(0, 20).join(' ') + '...';
  }
}
