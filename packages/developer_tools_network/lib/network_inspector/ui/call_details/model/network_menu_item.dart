import 'package:flutter/material.dart';

/// Definition of menu item used in call details.
class NetworkCallDetailsMenuItem {
  const NetworkCallDetailsMenuItem(this.title, this.iconData);

  final String title;
  final IconData iconData;
}

/// Definition of all call details menu item types.
enum NetworkCallDetailsMenuItemType { sort, delete, stats, save }
