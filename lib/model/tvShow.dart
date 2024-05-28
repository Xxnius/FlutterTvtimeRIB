class tvShow {
  final int id;
  final String name;
  final String imageThumbnailPath;

  // Constructeur par défaut
  tvShow({this.id = 0, this.name = '', this.imageThumbnailPath = ''});

  // Méthode pour convertir une instance de la classe en Map
  factory tvShow.fromJson(Map<String, dynamic> json) {
    return tvShow(
      id: json['id'],
      name: json['name'],
      imageThumbnailPath: json['image_thumbnail_path'],
    );
  }
}
