import 'package:flutter/material.dart';
import 'package:boxing_app/widgets/constants.dart';

class BottomButton extends StatelessWidget {
  final String bottomTitle;
  final VoidCallback onTap;

  const BottomButton({
    super.key,
    required this.bottomTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 18),
        width: double.infinity,
        decoration: BoxDecoration(
          color: kBottomContainerColor, // Now matches Timer screen
          borderRadius: BorderRadius.circular(16), // Unified rounding
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            bottomTitle.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
