class Application {
  final int id;
  final String nazvanie;
  final String opisanie;
  final String korpys;
  final String kabinet;
  final String ispolnitel;
  final String file;
  final String statusText;
  final String kategoria;

  Application({
    required this.id,
    required this.nazvanie,
    required this.opisanie,
    required this.korpys,
    required this.kabinet,
    required this.ispolnitel,
    required this.file,
    required this.statusText,
    required this.kategoria,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      nazvanie: json['nazvanie'].toString(),
      opisanie: json['opisanie'].toString(),
      korpys: json['korpys'].toString(),
      kabinet: json['kabinet'].toString(),
      ispolnitel: json['ispolnitel'].toString(),
      file: json['file'].toString(),
      statusText: json['statusText'].toString(),
      kategoria: json['kategoria'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nazvanie': nazvanie,
      'opisanie': opisanie,
      'korpys': korpys,
      'kabinet': kabinet,
      'ispolnitel': ispolnitel,
      'file': file,
      'statusText': statusText,
      'kategoria': kategoria,
    };
  }
}
