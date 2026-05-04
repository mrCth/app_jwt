class Anime {
  final int id;
  final String title;
  final String genre;

  Anime({required this.id, required this.title, required this.genre});

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(id: json['id'], title: json['title'], genre: json['genre']);
  }
}
