import 'package:flutter/material.dart';

class Count extends ChangeNotifier {
  int count = 0;

  void countIncreamented() {
    count += 1;
    notifyListeners();
  }
}
