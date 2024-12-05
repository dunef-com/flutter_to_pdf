import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;

import 'export_frame.dart';
import 'export_instance.dart';
import 'utils.dart';
import 'options/export_options.dart';
import 'options/font_data.dart';

/// The delegate handling the high-level export of the widget tree.
class ExportDelegate {
  final ExportOptions options;
  final FontData fontData;

  ExportDelegate({
    this.options = const ExportOptions(),
    Map<String, String> ttfFonts = const {},
  }) : fontData = FontData(ttfFonts);

  final Map<String, ExportFrameContext> _registeredFrames = {};

  /// Registers a new [ExportFrame] to the [ExportDelegate].
  void registerFrame(ExportFrameContext frame) {
    _registeredFrames[frame.frameId] = frame;
  }

  /// Returns the [ExportFrame] with the given [frameId].
  /// Throws an [Exception] if no [ExportFrame] is found.
  ExportFrameContext getFrame(String frameId) {
    final ExportFrameContext? frame = _registeredFrames[frameId];

    if (frame == null) {
      throw Exception('No frame with id $frameId found');
    }

    return frame;
  }

  /// Copies the [ExportDelegate] with the given [options].
  ExportDelegate copyWith({ExportOptions? options}) => ExportDelegate(
        options: options ?? this.options,
        ttfFonts: fontData.ttfFonts,
      );

  /// Exports the [ExportFrame] with the given [frameId] to a [pw.Document].
  Future<pw.Document> exportToPdfDocument(String frameId,
      {ExportOptions? overrideOptions}) async {
    final frame = getFrame(frameId);

    if (overrideOptions != null) {
      ExportDelegate delegate = copyWith(options: overrideOptions);
      return await delegate._exportDocument(
          frame.exportWidget, frame.exportContext);
    }

    return await _exportDocument(frame.exportWidget, frame.exportContext!);
  }

  /// Exports the [ExportFrame] with the given [frameId] to a [pw.Page].
  Future<pw.Page> exportToPdfPage(String frameId,
      {ExportOptions? overrideOptions}) async {
    final frame = getFrame(frameId);

    if (overrideOptions != null) {
      ExportDelegate delegate = copyWith(options: overrideOptions);
      return await delegate._exportPage(
          frame.exportWidget, frame.exportContext);
    }

    return await _exportPage(frame.exportWidget, frame.exportContext);
  }

  /// Exports the [ExportFrame] with the given [frameId] to a [pw.Widget].
  Future<pw.Widget> exportToPdfWidget(String frameId,
      {ExportOptions? overrideOptions}) async {
    final frame = getFrame(frameId);

    if (overrideOptions != null) {
      ExportDelegate delegate = copyWith(options: overrideOptions);
      return await delegate._exportWidget(
          frame.exportWidget, frame.exportContext);
    }

    return await _exportWidget(frame.exportWidget, frame.exportContext);
  }

  /// Exports the given [widget] to a [pw.Widget].
  /// If [context] is not null, the widgets´ state is provided.
  Future<pw.Widget> _exportWidget(Widget widget, BuildContext? context) async {
    final ExportInstance exportInstance =
        ExportInstance(this, (Widget widget) => _exportWidget(widget, null));

    final Size layoutSize = options.pageFormatOptions.getAvailableSize();

    double? pixelRatio;
    if (context != null) {
      fontData.setAssetBundleByContext(context);
      pixelRatio = MediaQuery.of(context).devicePixelRatio;
    }

    Element? element = layoutWidget(widget, layoutSize, pixelRatio);

    final List<pw.Widget> children =
        await exportInstance.matchWidget(element!, context);

    if (children.isEmpty) {
      throw Exception('No children found');
    }

    return children.first;
  }

  /// Exports the given [widget] to a [pw.Page].
  /// If [context] is not null, the widgets´ state is provided.
  Future<pw.Page> _exportPage(Widget widget, BuildContext? context) async {
    final pw.Widget pdfWidget = await _exportWidget(widget, context);

    return pw.Page(
      pageFormat: options.pageFormatOptions.getPageFormat(),
      clip: options.pageFormatOptions.clip,
      build: (pw.Context context) => pdfWidget,
    );
  }

  /// Exports the given [widget] to a [pw.Document].
  /// If [context] is not null, the widgets´ state is provided.
  Future<pw.Document> _exportDocument(
      Widget widget, BuildContext? context) async {
    final pw.Page pdfPage = await _exportPage(widget, context);

    final pw.Document pdf = pw.Document();

    pdf.addPage(pdfPage);

    return pdf;
  }

  // Wrap the private method _exportWidget
  // Exports unbuilted [widget].
  Future<pw.Widget> exportUnbuiltWidget(Widget widget) async =>
      await _exportWidget(widget, null);
}
