class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String? imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    this.imageUrl,
  });

  factory Article.fromMap(String id, Map<String, dynamic> data) {
    return Article(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}