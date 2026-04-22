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
          sectionsSpace: 3,
          centerSpaceRadius: 50,
          sections: widget.candidates.asMap().entries.map((e) {
            final isTouched = e.key == touchedIndex;
            return PieChartSectionData(
              color:       e.value.color,
              value:       e.value.percentage,
              title:       isTouched ? '${e.value.percentage.toStringAsFixed(1)}%' : '',
              radius:      isTouched ? 80 : 65,
              titleStyle:  const TextStyle(color: Colors.white,
                                           fontWeight: FontWeight.bold, fontSize: 13),
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}