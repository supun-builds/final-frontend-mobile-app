import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF4A90D9)
            : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
        style: TextStyle(
          color:      selected ? Colors.white : Colors.white38,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize:   13,
        )),
    ),
  );
}