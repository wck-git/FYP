import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final desktopBreakpoint = 999999; // change here for further implementation
  final Widget narrowLayout;
  final Widget wideLayout;

  ResponsiveLayout({
    required this.narrowLayout,
    required this.wideLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth < desktopBreakpoint
            ? narrowLayout
            : wideLayout;
      },
    );
  }
}
