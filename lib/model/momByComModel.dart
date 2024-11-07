class MOMByComModel {
  final int? tid;
  final int? fktid;
  final String? agenda;
  final String? fkmeeting;
  String? meeting;
  final String? remarks;
  String? commite;
  final String? mdate;
  final String? mtime;
  final String? venue;

  MOMByComModel({
    this.tid,
    this.fktid,
    this.agenda,
    this.fkmeeting,
    this.meeting,
    this.remarks,
    this.commite,
    this.mdate,
    this.mtime,
    this.venue,
  });

  MOMByComModel.fromJson(Map<String, dynamic> json)
      : tid = json['tid'] as int?,
        fktid = json['fktid'] as int?,
        agenda = json['agenda'] as String?,
        fkmeeting = json['fkmeeting'] as String?,
        meeting = json['meeting'] as String?,
        remarks = json['remarks'] as String?,
        commite = json['commite'] as String?,
        mdate = json['mdate'] as String?,
        mtime = json['mtime'] as String?,
        venue = json['venue'] as String?;

  Map<String, dynamic> toJson() => {
        'tid': tid,
        'fktid': fktid,
        'agenda': agenda,
        'fkmeeting': fkmeeting,
        'meeting': meeting,
        'remarks': remarks,
        'commite': commite,
        'mdate': mdate,
        'mtime': mtime,
        'venue': venue,
      };
}
