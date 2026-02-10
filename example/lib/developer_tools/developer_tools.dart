import 'package:flutter/material.dart';

class DeveloperToolsProvider extends StatefulWidget {
  const DeveloperToolsProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DeveloperToolsProvider> createState() => DeveloperToolsProviderState();

  static DeveloperToolsProviderState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DeveloperTools>()!.state;
  }
}

class DeveloperToolsProviderState extends State<DeveloperToolsProvider> {
  VoidCallback? onActionPressed;

  void updateAction(VoidCallback? callback) {
    setState(() {
      onActionPressed = callback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DeveloperTools(
      state: this,
      onActionPressed: onActionPressed,
      child: widget.child,
    );
  }
}

class DeveloperTools extends InheritedWidget {
  const DeveloperTools({
    super.key,
    required super.child,
    required this.state,
    this.onActionPressed,
  });

  final DeveloperToolsProviderState state;
  final VoidCallback? onActionPressed;

  @override
  bool updateShouldNotify(covariant DeveloperTools oldWidget) =>
      onActionPressed != oldWidget.onActionPressed;
}
