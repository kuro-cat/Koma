import 'package:flutter/material.dart';

/// Wraps a menu anchor's builder so system Back closes an open menu instead
/// of leaving the screen.
MenuAnchorChildBuilder closesOnBack(MenuAnchorChildBuilder builder) {
  return (context, controller, child) => MenuBackScope(
    controller: controller,
    child: builder(context, controller, child),
  );
}

class MenuBackScope extends StatefulWidget {
  const MenuBackScope({
    required this.controller,
    required this.child,
    super.key,
  });

  final MenuController controller;
  final Widget child;

  static final Set<MenuController> _open = {};

  /// Whether a menu was open when Back arrived. Every handler on the route
  /// hears the same Back, so the app shell checks this to leave the tab be.
  static bool get anyOpen => _open.isNotEmpty;

  @override
  State<MenuBackScope> createState() => _MenuBackScopeState();
}

class _MenuBackScopeState extends State<MenuBackScope> {
  @override
  void dispose() {
    MenuBackScope._open.remove(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    // The anchor rebuilds this when the menu opens or closes. A closed menu
    // leaves the set one frame later, so a handler that runs after ours
    // still sees that this Back belonged to the menu.
    if (controller.isOpen) {
      MenuBackScope._open.add(controller);
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => MenuBackScope._open.remove(controller),
      );
    }
    return PopScope(
      canPop: !controller.isOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && controller.isOpen) {
          controller.close();
        }
      },
      child: widget.child,
    );
  }
}
