import 'package:vidamais/models/Exam.dart';
import 'package:vidamais/models/Unit.dart';

class Schedule {
  final int id;
  final DateTime date;
  final String status;
  final String confirmCode;
  final List<Exam> exams;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final DateTime createdAt;
  final Unit? unit;

  Schedule({
    required this.id,
    required this.date,
    required this.status,
    required this.confirmCode,
    required this.exams,
    this.cancellationReason,
    this.cancellationDate,
    required this.createdAt,
    this.unit
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final rawExams = json['exams'] as List<dynamic>?;
    final examsList = rawExams != null
      ? rawExams.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList()
      : <Exam>[];

    return Schedule(
      id: json['id'] as int,
      date: DateTime.parse(json['scheduling_date'] as String),
      status: json['status'] as String,
      confirmCode: json['confirm_code'] as String,
      exams: examsList,
      cancellationReason: json['cancellation_reason'] as String?,
      cancellationDate: json['cancellation_date'] != null
          ? DateTime.parse(json['cancellation_date'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      unit: json['unit'] != null
          ? Unit.fromJson(json['unit'] as Map<String, dynamic>)
          : null,
    );
  }
}