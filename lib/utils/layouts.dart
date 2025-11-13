import 'package:flutter/material.dart';

class Layouts {
  static ThemeData getTheme(BuildContext context) {
    return Theme.of(context);
  }

  static Size getSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}
