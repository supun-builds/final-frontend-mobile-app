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
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidate.rank == 1
                  ? const Color(0xFF6B1124).withOpacity(0.4)
                  : const Color(0xFFE2E8F0),
              width: candidate.rank == 1 ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top colored accent bar matching candidate's party color
                Container(
                  height: 4,
                  color: candidate.color,
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Rank badge
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: candidate.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: candidate.color.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '#${candidate.rank}',
                                style: TextStyle(
                                  color: candidate.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Candidate name & party
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  candidate.candidateName,
                                  style: const TextStyle(
                                    color: Color(0xFF1A202C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  candidate.party,
                                  style: const TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Votes count & percentage
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_fmt(candidate.voteCount)}',
                                style: const TextStyle(
                                  color: Color(0xFF2D3748),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: candidate.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${candidate.percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: candidate.color,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalVotes > 0
                              ? candidate.voteCount / totalVotes
                              : 0,
                          backgroundColor: const Color(0xFFEDF2F7),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            candidate.color,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
