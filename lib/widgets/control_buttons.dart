import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool isPaused;

  const ControlButtons({
    super.key,
    required this.onPause,
    required this.onRestart,
    required this.onExit,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: onPause,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRestart,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}
