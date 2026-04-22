import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';

class VoteBarChart extends StatelessWidget {
  final List<Candidate> candidates;
  const VoteBarChart({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox();
    final maxVotes = candidates.map((c) => c.voteCount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxVotes * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= candidates.length) return const SizedBox();
                  // Show short name (first name only)
                  final name = candidates[idx].candidateName.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(name,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  );
                },
              ),
            ),
          ),
          barGroups: candidates.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.voteCount.toDouble(),
                color: e.value.color,
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVotes * 1.2,
                  color: Colors.grey.withOpacity(0.05),
                ),
              ),
            ],
          )).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}