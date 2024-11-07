class AgendaMeetimgModel {
  int? tid;
  String? tdate;
  String? mtime;
  String? refno;
  String? meeting;
  String? committe;
  String? rmks;
  String? fkmeeting;
  String? mdate;
  String? venue;
  String? fkcmt;
  String? zM_LINK;
  String? detail;

  AgendaMeetimgModel(
      {this.tid,
      this.tdate,
      this.mtime,
      this.refno,
      this.meeting,
      this.committe,
      this.rmks,
      this.fkmeeting,
      this.mdate,
      this.venue,
      this.fkcmt,
      this.zM_LINK,
      this.detail
      });

  AgendaMeetimgModel.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    tdate = json['tdate'];
    mtime = json['mtime'];
    refno = json['refno'];
    meeting = json['meeting'];
    committe = json['committe'];
    rmks = json['rmks'];
    fkmeeting = json['fkmeeting'];
    mdate = json['mdate'];
    venue = json['venue'];
    fkcmt = json['fkcmt'];
    zM_LINK = json['zM_LINK'];
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tid'] = this.tid;
    data['tdate'] = this.tdate;
    data['mtime'] = this.mtime;
    data['refno'] = this.refno;
    data['meeting'] = this.meeting;
    data['committe'] = this.committe;
    data['rmks'] = this.rmks;
    data['fkmeeting'] = this.fkmeeting;
    data['mdate'] = this.mdate;
    data['venue'] = this.venue;
    data['fkcmt'] = this.fkcmt;
    data['zM_LINK'] = this.zM_LINK;
    data['detail'] = this.detail;
    return data;
  }
}
