import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';

class VotePieChart extends StatefulWidget {
  final List<Candidate> candidates;
  const VotePieChart({super.key, required this.candidates});

  @override
  State<VotePieChart> createState() => _VotePieChartState();
}

class _VotePieChartState extends State<VotePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'දත්ත නොමැත (No data available)',
            style: TextStyle(color: Color(0xFF718096), fontSize: 13),
          ),
        ),
      );
    }

    final totalPercentage = widget.candidates.fold<double>(
      0.0,
      (sum, c) => sum + c.percentage,
    );

    if (totalPercentage <= 0) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'ඡන්ද වාර්තා වී නොමැත (No votes recorded yet)',
            style: TextStyle(color: Color(0xFF718096), fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                touchedIndex = (event.isInterestedForInteractions &&
                                response?.touchedSection != null)
                    ? response!.touchedSection!.touchedSectionIndex
                    : -1;
              });
            },
          ),
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          centerSpaceColor: Colors.white,
          sections: widget.candidates.asMap().entries.map((e) {
            final isTouched = e.key == touchedIndex;
            return PieChartSectionData(
              color: e.value.color,
              value: e.value.percentage,
              title: isTouched ? '${e.value.percentage.toStringAsFixed(1)}%' : '',
              radius: isTouched ? 75 : 62,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                shadows: [
                  Shadow(color: Colors.black45, blurRadius: 4),
                ],
              ),
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
