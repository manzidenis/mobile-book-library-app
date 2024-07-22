import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import 'preferences_provider.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  late Database _database;
  PreferencesProvider? _preferencesProvider;

  List<Book> get books => List.unmodifiable(_books);

  BookProvider(this._preferencesProvider) {
    _preferencesProvider?.addListener(_onPreferencesChanged);
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'books.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE books(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, author TEXT, rating REAL, isRead INTEGER, about TEXT, imagePath TEXT)',
        );
      },
      version: 1,
    );
    await loadBooks();
  }

  Future<void> loadBooks() async {
    final List<Map<String, dynamic>> maps = await _database.query('books');
    _books = List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    book.id = await _database.insert(
      'books',
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _books.add(book);
    notifyListeners();
  }

  Future<void> updateBook(Book book) async {
    await _database.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      notifyListeners();
    }
  }

  Future<void> deleteBook(int id) async {
    await _database.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    _books.removeWhere((book) => book.id == id);
    notifyListeners();
  }

  Future<void> updateBookRating(int id, double rating) async {
    await _database.update(
      'books',
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [id],
    );
    final book = _books.firstWhere((book) => book.id == id);
    if (book != null) {
      book.rating = rating;
      notifyListeners();
    }
  }

  Future<void> updateBookStatus(int id, bool isRead) async {
    await _database.update(
      'books',
      {'isRead': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    final book = _books.firstWhere((book) => book.id == id);
    if (book != null) {
      book.isRead = isRead;
      notifyListeners();
    }
  }

  void sortBooks(String criteria) {
    switch (criteria) {
      case 'title':
        _books.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'author':
        _books.sort((a, b) => a.author.compareTo(b.author));
        break;
      case 'rating':
        _books.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    notifyListeners();
  }

  void _onPreferencesChanged() {
    if (_preferencesProvider != null) {
      sortBooks(_preferencesProvider!.sortOrder);
    }
  }

  void updatePreferences(PreferencesProvider newPreferencesProvider) {
    _preferencesProvider?.removeListener(_onPreferencesChanged);
    _preferencesProvider = newPreferencesProvider;
    _preferencesProvider?.addListener(_onPreferencesChanged);
    if (_preferencesProvider != null) {
      sortBooks(_preferencesProvider!.sortOrder);
    }
  }
}
