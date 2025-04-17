import 'package:flutter/material.dart';
import 'package:boxing_app/widgets/constants.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 4.0,
      constraints: const BoxConstraints.tightFor(width: 60.0, height: 60.0),
      shape: const CircleBorder(),
      fillColor: kIconButtonsColor, // matches Timer screen
      child: Icon(
        icon,
        color: Colors.white, // Ensures visibility
        size: 28.0, // Slightly larger for better tap target
      ),
    );
  }
}
