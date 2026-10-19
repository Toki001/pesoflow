import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

/// Keep native back gestures and transition geometry, with brief task navigation.
abstract final class AppMotion {
  static const enter = Duration(milliseconds: 250);
  static const exit = Duration(milliseconds: 200);
}

class FinancePageTransitionsBuilder
    extends PredictiveBackPageTransitionsBuilder {
  const FinancePageTransitionsBuilder();
  @override
  Duration get transitionDuration => AppMotion.enter;
  @override
  Duration get reverseTransitionDuration => AppMotion.exit;
}

class FinanceCupertinoPageTransitionsBuilder
    extends CupertinoPageTransitionsBuilder {
  const FinanceCupertinoPageTransitionsBuilder();
  @override
  Duration get transitionDuration => AppMotion.enter;
  @override
  Duration get reverseTransitionDuration => AppMotion.exit;
}
