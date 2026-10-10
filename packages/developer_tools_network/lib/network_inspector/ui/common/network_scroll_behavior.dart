import 'dart:ui';

import 'package:material_ui/material_ui.dart';

/// Scroll behavior for NetworkInspector.
class NetworkScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
