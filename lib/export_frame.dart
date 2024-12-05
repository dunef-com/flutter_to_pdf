import 'package:flutter/material.dart';

import 'export_delegate.dart';

/// A widget that can be used to export a specific part of the widget tree.
class ExportFrame extends StatelessWidget {
  final String frameId;
  final ExportDelegate exportDelegate;
  final Widget child;

  const ExportFrame({
    required this.frameId,
    required this.exportDelegate,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    exportDelegate.registerFrame(ExportFrameContext(
        frameId: frameId,
        exportWidget: child,
        exportContext: context
    ));
    return child;
  }
}

class ExportFrameContext {
  final String frameId;
  final Widget exportWidget;
  final BuildContext exportContext;

  ExportFrameContext({
    required this.frameId,
    required this.exportWidget,
    required this.exportContext
  });
}
