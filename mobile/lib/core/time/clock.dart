import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Override in tests; no frozen financial dates in the production runtime.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
