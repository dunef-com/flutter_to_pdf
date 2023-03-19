import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'traversal.dart';


/// Extracts the ExportFrame as [Element] from the provided [element]. 
/// ExportFrame is identified by checking if the widget contains the [exportFrameKey].
Element? extractExportFrame(Element element) {
  if (element.widget.key == exportFrameKey) {
    return element;
  }

  List<Element> children = [];
  element.visitChildren((Element e) {
    children.add(e);
  });

  for (Element child in children) {
    Element? found = extractExportFrame(child);
    if (found != null) {
      return found;
    }
  }
  return null;
}

/// Finds the first [Element] in the provided [context] 
/// that matches the provided [compare] function.
Element? findElement<T>(BuildContext context, bool Function(T) compare) {
  Element? element;

  context.visitChildElements((Element e) => element = e);

  return findByElement(element!, compare);
}

/// Recursive helper function for [findElement].
Element? findByElement<T>(Element element, bool Function(T) compare) {
  if (element.widget is T && compare(element.widget as T)) {
    return element;
  }

  List<Element> children = [];
  element.visitChildren((Element e) {
    children.add(e);
  });


  for (Element child in children) {
    Element? found = findByElement(child, compare);
    if (found != null) {
      return found;
    }
  }
  return null;
}

/// Lays out the provided [widget] in a view of [size] and returns it as [Element].
Future<Element?> layoutWidget(Widget widget, Size size) async {
  RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  RenderView renderView = RenderView(
    configuration: ViewConfiguration(
      size: size,
      devicePixelRatio: 1.0,
    ),
    window: WidgetsBinding.instance.platformDispatcher.views.first,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
  );

  PipelineOwner pipelineOwner = PipelineOwner();
  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  RenderObjectToWidgetElement rootElement = RenderObjectToWidgetAdapter(
    container: repaintBoundary,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: Material(
          child: Directionality(
            key: exportFrameKey, // TODO: check if exportFrameKey can also be added to the ExportFrame
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  Element? element;

  rootElement.visitChildren((Element child) => element = child);

  Element? exportFrameElement = extractExportFrame(element!);

  return exportFrameElement;
}
