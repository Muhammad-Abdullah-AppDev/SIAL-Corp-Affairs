import 'package:flutter/material.dart';

class Meeting {
  Meeting(
      this.tid,
      this.EventName,
      this.from,
      this.to,
      this.Background,
      this.isAllDay,
      this.mtime,
      this.comName,
      this.venue,
      this.meettime,
      );

  int tid;
  String EventName;
  DateTime from;
  DateTime to;
  Color Background;
  bool isAllDay;
  String mtime;
  String comName;
  String venue;
  String meettime;

  // Implement equality and hashCode based on tid and meeting date
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Meeting &&
              runtimeType == other.runtimeType &&
              tid == other.tid &&
              from == other.from;

  @override
  int get hashCode => hashValues(tid, from);
}