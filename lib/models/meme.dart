class Meme {
  final int id;
  final String name;
  final String fileUrl;

  Meme({this.id, this.name, this.fileUrl});
  
  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      id: json['id'],
      name: json['name'],
      fileUrl: json['file_url']
    );
  }
}