import 'package:flutter/cupertino.dart';

enum TagleMode {
  normal,
  child,
}

class Mode with ChangeNotifier {
  TagleMode _value = TagleMode.normal;

  TagleMode get value => _value;
  set value(TagleMode m) {
    _value = m;
    notifyListeners();
  }
}
