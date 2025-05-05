import 'models/card_model.dart';
import 'dart:math';

class LevelManager {
  static List<CardModel> generateLevel(int level) {
    int pairCount;
    if (level <= 20) {
      pairCount = 10;
    } else if (level <= 40) {
      pairCount = 15;
    } else {
      pairCount = 25;
    }

    List<String> images = List.generate(pairCount, (i) => 'assets/images/img_${i % 10}.png');
    List<CardModel> cards = [];
    for (var img in images) {
      cards.add(CardModel(image: img));
      cards.add(CardModel(image: img));
    }
    cards.shuffle(Random());
    return cards;
  }
}
