import 'package:flutter/material.dart';

class AddChip extends StatelessWidget {
  const AddChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF817CFF)),
        ),
        child: const Icon(Icons.add, size: 18, color: Color(0xFF6F68FF)),
      ),
    );
  }
}
