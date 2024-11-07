class MomModel {
  int? tid;
  int? fktid;
  String? agenda;
  String? fkmeeting;
  String? meeting;
  String? remarks;
  String? mdate;
  String? mtime;
  String? commite;
  String? venue;
  String? agendadtl;
  String? momfotitem;
  String? momfotdtl;

  MomModel({
    this.tid,
    this.fktid,
    this.agenda,
    this.fkmeeting,
    this.meeting,
    this.remarks,
    this.mdate,
    this.mtime,
    this.commite,
    this.venue,
    this.agendadtl,
    this.momfotitem,
    this.momfotdtl,
  });

  MomModel.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    fktid = json['fktid'];
    agenda = json['agenda'];
    fkmeeting = json['fkmeeting'];
    meeting = json['meeting'];
    remarks = json['remarks'];
    mdate = json['mdate'];
    mtime = json['mtime'];
    commite = json['commite'];
    venue = json['venue'];
    agendadtl = json['agendadtl'];
    momfotitem = json['momfotitem'];
    momfotdtl = json['momfotdtl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tid'] = this.tid;
    data['fktid'] = this.fktid;
    data['agenda'] = this.agenda;
    data['fkmeeting'] = this.fkmeeting;
    data['meeting'] = this.meeting;
    data['remarks'] = this.remarks;
    data['mdate'] = this.mdate;
    data['mtime'] = this.mtime;
    data['commite'] = this.commite;
    data['venue'] = this.venue;
    data['agendadtl'] = this.agendadtl;
    data['momfotitem'] = this.momfotitem;
    data['momfotdtl'] = this.momfotdtl;
    return data;
  }
}
