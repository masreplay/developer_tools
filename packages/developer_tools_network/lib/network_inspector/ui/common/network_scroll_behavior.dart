import 'dart:ui';

import 'package:flutter/material.dart';

/// Scroll behavior for NetworkInspector.
class NetworkScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
