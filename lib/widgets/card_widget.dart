import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: card.isFlipped
              ? Image.asset(card.image, fit: BoxFit.cover)
              : const Icon(Icons.help_outline, size: 40, color: Colors.blue),
        ),
      ),
    );
  }
}
