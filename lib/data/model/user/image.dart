class Image {
  String? file;
  String? thumbnail;
  String? midsize;
  String? fullsize;

  Image({this.file, this.thumbnail, this.midsize, this.fullsize});

  factory Image.fromJson(Map<String, dynamic> json) {
   return Image(
      file: json['file'],
      thumbnail: json['thumbnail'],
      midsize: json['midsize'],
      fullsize: json['fullsize'],
   );
  }
}