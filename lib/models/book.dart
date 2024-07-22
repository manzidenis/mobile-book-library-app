class Book {
  int? id;
  String title;
  String author;
  double rating;
  bool isRead;
  String? about;
  String? imagePath;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.isRead,
    required this.about,
    required this.imagePath,
  });

  // Add fromMap and toMap methods
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
      rating: (map['rating'] as num).toDouble(),  // Ensure rating is treated as double
      isRead: map['isRead'] == 1,
      about: map['about'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'rating': rating,
      'isRead': isRead ? 1 : 0,
      'about': about,
      'imagePath': imagePath,
    };
  }
}
