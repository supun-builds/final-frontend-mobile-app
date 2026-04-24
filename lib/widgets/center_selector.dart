import 'package:flutter/material.dart';

class CenterSelector extends StatelessWidget {
  final List<Map<String, dynamic>> centers;
  final String? selectedCenterId;
  final ValueChanged<String?> onChanged;

  const CenterSelector({
    super.key,
    required this.centers,
    required this.selectedCenterId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1525),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Voting Center',
          style: TextStyle(color: Colors.white38, fontSize: 11,
                           letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2035),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedCenterId,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A2035),
              iconEnabledColor: Colors.white38,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                // overall
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Row(children: [
                    Icon(Icons.public, color: Color(0xFF4A90D9), size: 16),
                    SizedBox(width: 10),
                    Text('Overall — All Centers'),
                  ]),
                ),
                // divider
                const DropdownMenuItem<String?>(
                  enabled: false,
                  value: 'divider',
                  child: Divider(color: Colors.white12),
                ),
                // centers
                ...centers.map((c) => DropdownMenuItem<String?>(
                  value: c['centerId'] as String,
                  child: Row(children: [
                    const Icon(Icons.location_on,
                      color: Color(0xFF1D9E75), size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      c['centerName'] as String,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                )),
              ],
              onChanged: (val) {
                if (val != 'divider') onChanged(val);
              },
            ),
          ),
        ),
      ]),
    );
  }
}