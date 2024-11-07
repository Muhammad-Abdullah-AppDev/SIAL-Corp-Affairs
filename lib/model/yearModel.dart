class YearModel {
  final String pkcode;
  final DateTime frdt;
  final DateTime todt;
  final String name;
  final dynamic meeting;

  YearModel({
    required this.pkcode,
    required this.frdt,
    required this.todt,
    required this.name,
    required this.meeting,
  });

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      pkcode: json['pkcode'],
      frdt: DateTime.parse(json['frdt']),
      todt: DateTime.parse(json['todt']),
      name: json['name'],
      meeting: json['meeting'],
    );
  }
}
