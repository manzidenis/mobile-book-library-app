import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/book_provider.dart';
import '../../models/book.dart';
import '../book_detail/book_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  SearchScreen({required this.query});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final results = bookProvider.books
        .where((book) =>
    book.title.toLowerCase().contains(query.toLowerCase()) ||
        book.author.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: results.isEmpty
          ? Center(
        child: Text(
          'No such book is found',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final book = results[index];
          final imagePath = book.imagePath;
          final file = imagePath != null ? File(imagePath) : null;

          return ListTile(
            leading: file != null && file.existsSync()
                ? Image.file(
              file,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 50, color: Colors.red);
              },
            )
                : Icon(Icons.book, size: 50),
            title: Text(book.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('By: '),
                    Text(book.author),
                    SizedBox(width: 4),
                    Text('  •  '),
                    SizedBox(width: 4),
                    Text('${book.rating}'),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text('  •  '),
                    SizedBox(width: 4),
                    Text('${book.isRead ? 'Read' : 'Unread'}'),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(book: book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
