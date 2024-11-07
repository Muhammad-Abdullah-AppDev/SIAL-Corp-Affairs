class UpComingMeetingModel {
  int? tid;
  String? tdate;
  String? refno;
  String? meeting;
  String? committe;
  String? rmks;
  String? fkmeeting;
  String? mdate;
  String? venue;
  String? fkcmt;
  String? mtime;
  String? zM_LINK;
  String? meettime;

  UpComingMeetingModel({
    this.tid,
    this.tdate,
    this.refno,
    this.meeting,
    this.committe,
    this.rmks,
    this.fkmeeting,
    this.mdate,
    this.venue,
    this.fkcmt,
    this.mtime,
    this.zM_LINK,
    this.meettime,
  });

  UpComingMeetingModel.fromJson(Map<String, dynamic> json) {
    tid = json['tid'];
    tdate = json['tdate'];
    refno = json['refno'];
    meeting = json['meeting'];
    committe = json['committe'];
    rmks = json['rmks'];
    fkmeeting = json['fkmeeting'];
    mdate = json['mdate'];
    venue = json['venue'];
    fkcmt = json['fkcmt'];
    mtime = json['mtime'];
    zM_LINK = json['zM_LINK'];
    meettime = json['meettime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tid'] = this.tid;
    data['tdate'] = this.tdate;
    data['refno'] = this.refno;
    data['meeting'] = this.meeting;
    data['committe'] = this.committe;
    data['rmks'] = this.rmks;
    data['fkmeeting'] = this.fkmeeting;
    data['mdate'] = this.mdate;
    data['venue'] = this.venue;
    data['fkcmt'] = this.fkcmt;
    data['mtime'] = this.mtime;
    data['zM_LINK'] = this.zM_LINK;
    data['meettime'] = this.meettime;
    return data;
  }
}
