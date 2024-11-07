class AgendaMeetingByComModel {
  final int? tid;
  final String? tdate;
  final String? refno;
  final String? meeting;
  String? committe;
  final String? rmks;
  final String? fkmeeting;
  final String? mdate;
  final String? venue;
  final String? fkcmt;
  final String? zMLINK;
  final String? mtime;
  final dynamic meettime;

  AgendaMeetingByComModel({
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
    this.zMLINK,
    this.mtime,
    this.meettime,
  });

  AgendaMeetingByComModel.fromJson(Map<String, dynamic> json)
      : tid = json['tid'] as int?,
        tdate = json['tdate'] as String?,
        refno = json['refno'] as String?,
        meeting = json['meeting'] as String?,
        committe = json['committe'] as String?,
        rmks = json['rmks'] as String?,
        fkmeeting = json['fkmeeting'] as String?,
        mdate = json['mdate'] as String?,
        venue = json['venue'] as String?,
        fkcmt = json['fkcmt'] as String?,
        zMLINK = json['zM_LINK'] as String?,
        mtime = json['mtime'] as String?,
        meettime = json['meettime'];

  Map<String, dynamic> toJson() => {
        'tid': tid,
        'tdate': tdate,
        'refno': refno,
        'meeting': meeting,
        'committe': committe,
        'rmks': rmks,
        'fkmeeting': fkmeeting,
        'mdate': mdate,
        'venue': venue,
        'fkcmt': fkcmt,
        'zM_LINK': zMLINK,
        'mtime': mtime,
        'meettime': meettime
      };
}
