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
      color: const Color(0xFF6B1124), // Official deep maroon bar
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Color(0xFFF1C40F), // Gold accent
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedCenterId,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  iconEnabledColor: const Color(0xFFF1C40F),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '🏛 Overall — All Centers Combined',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(), // divider
                      ...centers.map((c) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '📍 ${c['centerName']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                    ];
                  },
                  items: [
                    // overall
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.public, color: Color(0xFF6B1124), size: 16),
                          SizedBox(width: 10),
                          Text(
                            'Overall — All Centers',
                            style: TextStyle(
                              color: Color(0xFF1A202C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const DropdownMenuItem<String?>(
                      enabled: false,
                      value: 'divider',
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    // centers
                    ...centers.map((c) => DropdownMenuItem<String?>(
                          value: c['centerId'] as String,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                color: Color(0xFF6B1124),
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  c['centerName'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) {
                    if (val != 'divider') onChanged(val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
