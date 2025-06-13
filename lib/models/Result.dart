import 'package:flutter/foundation.dart';
import 'package:vidamais/models/Schedule.dart';

enum StatusResult {
  pendente,
  disponivel,
  assinado,
}

class Result {
  final int id;
  final Schedule scheduling;
  final int schedulingId;
  final String? textResult;
  final String fileResult;
  final DateTime dateAvailability;
  final StatusResult status;
  final String? digitalSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  Result({
    required this.id,
    required this.scheduling,
    this.textResult,
    required this.fileResult,
    required this.dateAvailability,
    required this.status,
    this.digitalSignature,
    required this.createdAt,
    required this.updatedAt,
    required this.schedulingId
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'] as int,
      scheduling: Schedule.fromJson(json['scheduling']),
      // schedulingId: json['scheduling_id'] as int,
      schedulingId: json['scheduling']?['id'] as int,
      textResult: json['text_result'] as String?,
      fileResult: json['file_result'] as String,
      dateAvailability: DateTime.parse(json['date_availability'] as String),
      status: _statusFromString(json['status'] as String),
      digitalSignature: json['digital_signature'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }


  static StatusResult _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return StatusResult.pendente;
      case 'disponível':
        return StatusResult.disponivel;
      case 'assinado':
        return StatusResult.assinado;
      default:
        throw Exception('Status inválido: $status');
    }
  }
  

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'scheduling': scheduling.toJson(),
      'text_result': textResult,
      'file_result': fileResult,
      'date_availability': dateAvailability.toIso8601String(),
      'status': describeEnum(status),
      'digital_signature': digitalSignature,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}