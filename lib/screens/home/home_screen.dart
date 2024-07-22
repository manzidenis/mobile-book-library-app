import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../add_edit_book/add_edit_book_screen.dart';
import '../book_detail/book_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';
import '../../providers/preferences_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    setState(() {
      _filteredBooks = bookProvider.books
          .where((book) =>
      book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query))
          .toList();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a search term'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => SearchScreen(query: query),
        ),
      )
          .then((_) {
        _searchController.clear();
        _filterBooks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookProvider, PreferencesProvider>(
      builder: (context, bookProvider, preferencesProvider, child) {
        final books = _filteredBooks.isEmpty ? bookProvider.books : _filteredBooks;
        final isDarkMode = preferencesProvider.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'MyBook Library',
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
            actions: [
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or author',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: books.length,
                  itemBuilder: (ctx, i) {
                    final book = books[i];
                    final imagePath = book.imagePath;
                    final file = imagePath != null ? File(imagePath) : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  image: file != null && file.existsSync()
                                      ? DecorationImage(
                                    image: FileImage(file),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                  color: file == null || !file.existsSync()
                                      ? Colors.grey[300]
                                      : null,
                                ),
                                child: file == null || !file.existsSync()
                                    ? Icon(
                                  Icons.book,
                                  size: 60,
                                  color: Colors.grey,
                                )
                                    : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                book.author,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text('${book.rating}'),
                                  Spacer(),
                                  Text(
                                    book.isRead ? 'Read' : 'Unread',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(Icons.add),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditBookScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
