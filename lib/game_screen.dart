import 'dart:async';
// ignore: unused_import
import 'dart:math';
import 'package:flutter/material.dart';

import 'models/card_model.dart';
import 'widgets/card_widget.dart';
import 'widgets/level_complete_popup.dart';
import 'level_manager.dart';
import 'utils/storage_helper.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final Function(int) onLevelComplete;

  const GameScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int unlockedLevel = 1;

  late List<CardModel> cards;
  int moves = 0;
  int correctMatches = 0;
  int wrongMatches = 0;
  bool isPaused = false;
  Timer? timer;
  int secondsPassed = 0;

  CardModel? firstFlipped;

  @override
  void initState() {
    super.initState();
    cards = LevelManager.generateLevel(widget.level);
    startTimer();
  }

  void _loadProgress() async {
    int level = await StorageHelper.getUnlockedLevel();
    setState(() => unlockedLevel = level);
  }

  void _onLevelComplete(int level) async {
    if (level >= unlockedLevel) {
      await StorageHelper.saveUnlockedLevel(level + 1);
      setState(() => unlockedLevel = level + 1);
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          secondsPassed++;
        });
      }
    });
  }

  void resetGame() {
    setState(() {
      moves = 0;
      correctMatches = 0;
      wrongMatches = 0;
      secondsPassed = 0;
      firstFlipped = null;
      cards = LevelManager.generateLevel(widget.level);
    });
  }

  void onCardTap(CardModel card) {
    if (card.isFlipped || isPaused) return;

    setState(() {
      card.isFlipped = true;
      if (firstFlipped == null) {
        firstFlipped = card;
      } else {
        moves++;
        if (firstFlipped!.image == card.image) {
          correctMatches++;
          firstFlipped = null;
          if (correctMatches == cards.length ~/ 2) {
            timer?.cancel();
            StorageHelper.saveUnlockedLevel(widget.level + 1);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Level Completed!'),
                content: Text('Time: $secondsPassed s\nMoves: $moves'),
                actions: [
                  TextButton(
                    onPressed: () {
                      StorageHelper.saveUnlockedLevel(widget.level + 1);
                      Navigator.pop(context); // close dialog
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      ); // back to home
                    },
                    child: const Text('Home'),
                  ),
                  TextButton(
                    onPressed: () {
                      StorageHelper.saveUnlockedLevel(widget.level + 1);
                      Navigator.pop(context);
                      resetGame();
                    },
                    child: const Text('Restart'),
                  ),
                  TextButton(
                    onPressed: () {
                      StorageHelper.saveUnlockedLevel(widget.level + 1);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            level: widget.level + 1,
                            onLevelComplete: widget.onLevelComplete,
                          ),
                        ),
                      );
                    },
                    child: const Text('Next Level'),
                  ),
                ],
              ),
            );

            // showDialog(
            //   context: context,
            //   barrierDismissible: false,
            //   builder: (_) => LevelCompletePopup(
            //     onNext: widget.level < 50
            //         ? () {
            //             Navigator.pop(context);
            //             StorageHelper.saveUnlockedLevel(widget.level + 1);
            //             Navigator.pushReplacement(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (_) => GameScreen(level: widget.level + 1, onLevelComplete: _onLevelComplete)
            //               ),
            //             ).then((_) => _loadProgress());
            //           }
            //         : null,
            //     onRestart: () {
            //       Navigator.pop(context);
            //       resetGame();
            //     },
            //     onHome: () {
            //       StorageHelper.saveUnlockedLevel(widget.level + 1);
            //       Navigator.of(context).pushReplacement(
            //         MaterialPageRoute(builder: (_) => const HomeScreen()),
            //       );
            //     },
            //     Text: '',
            //   ),
            // ).then((_) => _loadProgress());
          }
        } else {
          wrongMatches++;
          isPaused = true;
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              card.isFlipped = false;
              firstFlipped!.isFlipped = false;
              firstFlipped = null;
              isPaused = false;
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const cardSpacing = 10.0;
    const idealCardSize = 80.0;
    final crossAxisCount =
        (screenWidth / (idealCardSize + cardSpacing)).floor();
    // int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 6 : 4;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text('Level ${widget.level}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Moves: $moves'),
                Text('Correct: $correctMatches'),
                Text('Wrong: $wrongMatches'),
                Text('Time: $secondsPassed s'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(cardSpacing),
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: cardSpacing,
                  mainAxisSpacing: cardSpacing,
                ),
                itemBuilder: (context, index) => CardWidget(
                  card: cards[index],
                  onTap: () => onCardTap(cards[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




//   void _initializeCards() {
//     int pairCount = cardCount ~/ 2;
//     List<int> pairValues = List.generate(pairCount, (index) => index);
//     List<int> allValues = [...pairValues, ...pairValues];
//     allValues.shuffle();

//     cards = List.generate(
//       cardCount,
//       (index) => _CardModel(value: allValues[index]),
//     );
//   }

//   void _startTimer() {
//     gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       setState(() => elapsedSeconds++);
//     });
//   }

//   void _stopTimer() {
//     gameTimer?.cancel();
//   }

//   void _restartGame() {
//     setState(() {
//       totalMoves = 0;
//       correctMatches = 0;
//       wrongMatches = 0;
//       elapsedSeconds = 0;
//       selectedIndices.clear();
//       _initializeCards();
//       _startTimer();
//     });
//   }

//   void _onCardTap(int index) {
//     if (cards[index].isFlipped || selectedIndices.length == 2) return;

//     setState(() {
//       cards[index].isFlipped = true;
//       selectedIndices.add(index);
//     });

//     if (selectedIndices.length == 2) {
//       totalMoves++;
//       final first = cards[selectedIndices[0]];
//       final second = cards[selectedIndices[1]];

//       if (first.value == second.value) {
//         correctMatches++;
//         selectedIndices.clear();
//         if (correctMatches == cardCount ~/ 2) _onWin();
//       } else {
//         wrongMatches++;
//         Future.delayed(const Duration(milliseconds: 800), () {
//           setState(() {
//             cards[selectedIndices[0]].isFlipped = false;
//             cards[selectedIndices[1]].isFlipped = false;
//             selectedIndices.clear();
//           });
//         });
//       }
//     }
//   }

//   void _onWin() {
//     _stopTimer();
//     widget.onLevelComplete(widget.level);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Level Completed!'),
//         content: Text('Time: $elapsedSeconds s\nMoves: $totalMoves'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // close dialog
//               Navigator.pop(context); // back to home
//             },
//             child: const Text('Home'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _restartGame();
//             },
//             child: const Text('Restart'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => GameScreen(
//                     level: widget.level + 1,
//                     onLevelComplete: widget.onLevelComplete,
//                   ),
//                 ),
//               );
//             },
//             child: const Text('Next Level'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _stopTimer();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     const cardSpacing = 10.0;
//     const idealCardSize = 80.0;
//     final crossAxisCount = (screenWidth / (idealCardSize + cardSpacing)).floor();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Level ${widget.level}'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _restartGame,
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Text('Moves: $totalMoves'),
//                 Text('Correct: $correctMatches'),
//                 Text('Wrong: $wrongMatches'),
//                 Text('Time: $elapsedSeconds s'),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(cardSpacing),
//               child: GridView.builder(
//                 itemCount: cards.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: cardSpacing,
//                   mainAxisSpacing: cardSpacing,
//                 ),
//                 itemBuilder: (context, index) {
//                   return _buildCard(index);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard(int index) {
//     final card = cards[index];
//     return GestureDetector(
//       onTap: () => _onCardTap(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         decoration: BoxDecoration(
//           color: card.isFlipped ? Colors.amber : Colors.blueGrey,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: card.isFlipped
//               ? [
//                   const BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 6,
//                     offset: Offset(2, 2),
//                   )
//                 ]
//               : [],
//         ),
//         child: Center(
//           child: card.isFlipped
//               ? Text(
//                   '${card.value}',
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 )
//               : const Icon(Icons.help, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// class _CardModel {
//   final int value;
//   bool isFlipped = false;

//   _CardModel({required this.value});
// }
