import 'dart:async';

import 'package:flutter/foundation.dart';

/// Coalesces rapid calls (search input, filter toggles). Dispose to cancel a
/// pending run.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  bool get isPending => _timer?.isActive ?? false;

  void cancel() => _timer?.cancel();

  void dispose() => _timer?.cancel();
}
