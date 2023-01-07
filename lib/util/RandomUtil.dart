
import 'dart:math';

class RandomUtil{

  static Random _random = Random();

  static int next(int min, int max) => min + _random.nextInt(max - min);

}