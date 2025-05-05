import 'package:flutter/material.dart';

class LevelCompletePopup extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const LevelCompletePopup({
    super.key,
    this.onNext,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Level Complete!'),
      content: const Text('Choose an option:'),
      actions: [
        if (onNext != null)
          TextButton(
            onPressed: onNext,
            child: const Text('Next Level'),
          ),
        TextButton(
          onPressed: onRestart,
          child: const Text('Restart'),
        ),
        TextButton(
          onPressed: onHome,
          child: const Text('Home'),
        ),
      ],
    );
  }
}
