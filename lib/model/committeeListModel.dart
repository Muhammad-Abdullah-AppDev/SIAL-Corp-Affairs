class CommitteeListModel {
  String? pkcode;
  String? name;

  CommitteeListModel({this.pkcode, this.name});

  CommitteeListModel.fromJson(Map<String, dynamic> json) {
    pkcode = json['pkcode'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkcode'] = this.pkcode;
    data['name'] = this.name;
    return data;
  }
}