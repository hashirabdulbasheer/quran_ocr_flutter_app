import 'package:noble_quran/models/word.dart';

class QRWord {
  NQWord word;
  double similarityScore;

  QRWord({required this.word, required this.similarityScore});
}
