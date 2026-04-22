
import 'package:flutter/material.dart';
class Candidate {
  final String candidateId;
  final String candidateName;
  final String party;
  final String partyColor;
  final int    voteCount;
  final double percentage;
  final int    rank;

  Candidate({
    required this.candidateId,
    required this.candidateName,
    required this.party,
    required this.partyColor,
    required this.voteCount,
    required this.percentage,
    required this.rank,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    candidateId:   json['candidateId']   ?? '',
    candidateName: json['candidateName'] ?? '',
    party:         json['party']         ?? '',
    partyColor:    json['partyColor']    ?? '#4A90D9',
    voteCount:     json['voteCount']     ?? 0,
    percentage:    double.tryParse(json['percentage'].toString()) ?? 0.0,
    rank:          json['rank']          ?? 0,
  );

  // Convert hex string to Flutter Color
  Color get color {
    final hex = partyColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}