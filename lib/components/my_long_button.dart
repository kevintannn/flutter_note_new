import 'package:flutter/material.dart';

class MyLongButton extends StatelessWidget {
  final void Function()? onTap;
  final Color? color;
  final String label;

  const MyLongButton({
    super.key,
    required this.onTap,
    this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
