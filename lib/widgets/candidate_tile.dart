import 'package:flutter/material.dart';
import '../models/candidate.dart';

class CandidateTile extends StatelessWidget {
  final Candidate candidate;
  final int totalVotes;

  const CandidateTile({
    super.key,
    required this.candidate,
    required this.totalVotes,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: candidate.rank == 1
              ? candidate.color.withOpacity(0.5)
              : Colors.white.withOpacity(0.06),
          width: candidate.rank == 1 ? 1.5 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // rank badge
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: candidate.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text('#${candidate.rank}',
              style: TextStyle(color: candidate.color,
                               fontSize: 12,
                               fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          // name + party
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(candidate.candidateName,
                style: const TextStyle(color: Colors.white,
                                       fontWeight: FontWeight.w600,
                                       fontSize: 14)),
              Text(candidate.party,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )),
          // votes + percentage
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${_fmt(candidate.voteCount)} votes',
              style: const TextStyle(color: Colors.white70,
                                     fontWeight: FontWeight.w600,
                                     fontSize: 13)),
            Text('${candidate.percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: candidate.color, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 10),
        // progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: totalVotes > 0 ? candidate.voteCount / totalVotes : 0,
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(candidate.color),
            minHeight: 6,
          ),
        ),
      ]),
    ),
  );
}