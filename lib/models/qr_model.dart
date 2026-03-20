class QRModel {
  String title;
  String observation;
  String url;
  String datetime;
  QRModel(
      {required this.title,
      required this.observation,
      required this.url,
      required this.datetime});
  factory QRModel.fromJson(Map<String, dynamic> json) => QRModel(
      title: json["title"] ?? "",
      observation: json["observation"] ?? "",
      url: json["url"] ?? "",
      datetime: json["datetime"] ?? "");
  Map<String, dynamic> toJson() => {
        "title": title,
        "observation": observation,
        "url": url,
        "datetime": datetime
      };
}
