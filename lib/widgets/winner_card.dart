import 'package:flutter/material.dart';
import '../models/candidate.dart';

class WinnerCard extends StatelessWidget {
  final Candidate leader;
  final int totalVotes;

  const WinnerCard({super.key, required this.leader, required this.totalVotes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [leader.color.withOpacity(0.8), leader.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: leader.color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            const Text('CURRENT LEADER',
              style: TextStyle(color: Colors.white70, fontSize: 12,
                              fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          Text(leader.candidateName,
            style: const TextStyle(color: Colors.white, fontSize: 24,
                                   fontWeight: FontWeight.bold)),
          Text(leader.party,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 16),
          Row(children: [
            _StatChip(
              label: 'Votes',
              value: leader.voteCount.toString(),
            ),
            const SizedBox(width: 12),
            _StatChip(
              label: 'Share',
              value: '${leader.percentage.toStringAsFixed(1)}%',
            ),
          ],),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white,
                                         fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );
}