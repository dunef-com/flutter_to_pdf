import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:pdf/widgets.dart' as pw;

late pw.Document pdf;
final ExportDelegate exportDelegate = ExportDelegate();
final ExportOptions overrideOptions = ExportOptions(
  checkboxOptions: CheckboxOptions.uniform(interactive: false),
);

void main() {
  setUpAll(() {
    pw.Document.debug = true;
    pdf = pw.Document();
  });

  testWidgets('Form Widgets Checkbox Basic', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ExportFrame(
          frameId: 'checkbox basic',
          exportDelegate: exportDelegate,
          child: const Row(
            children: <Widget>[
              Checkbox(
                key: Key('checkbox1 basic'),
                value: true,
                onChanged: null,
              ),
              Checkbox(
                key: Key('checkbox2 basic'),
                value: false,
                onChanged: null,
              ),
            ],
          ),
        ),
      ),
    ));

    pdf.addPage(await exportDelegate.exportToPdfPage('checkbox basic'));
    pdf.addPage(await exportDelegate.exportToPdfPage('checkbox basic',
        overrideOptions: overrideOptions));
  });

  testWidgets('Form Widgets Checkbox Decoration', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: ExportFrame(
          frameId: 'checkbox decoration',
          exportDelegate: exportDelegate,
          child: const Row(
            children: <Widget>[
              Checkbox(
                key: Key('checkbox1 decoration'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                activeColor: Colors.purple,
                checkColor: Colors.green,
                value: true,
                onChanged: null,
              ),
              Checkbox(
                key: Key('checkbox2 decoration'),
                shape: CircleBorder(
                  side: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                activeColor: Colors.purple,
                checkColor: Colors.green,
                value: false,
                onChanged: null,
              ),
            ],
          ),
        ),
      ),
    ));

    pdf.addPage(await exportDelegate.exportToPdfPage('checkbox decoration'));
    pdf.addPage(await exportDelegate.exportToPdfPage('checkbox decoration',
        overrideOptions: overrideOptions));
  });

  testWidgets('Form Widgets Button Basic', (tester) async {
    await tester.pumpWidget(ExportFrame(
      frameId: 'button basic',
      exportDelegate: exportDelegate,
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              onPressed: null,
              child: Text('TextButton'),
            ),
            ElevatedButton(
              onPressed: null,
              child: Text('ElevatedButton'),
            ),
            OutlinedButton(
              onPressed: null,
              child: Text('OutlinedButton'),
            ),
            FilledButton(
              onPressed: null,
              child: Text('FilledButton'),
            ),
          ],
        ),
      ),
    ));

    pdf.addPage(await exportDelegate.exportToPdfPage('button basic'));
  });

  testWidgets('Form Widgets Button Style', (tester) async {
    await tester.pumpWidget(ExportFrame(
      frameId: 'button style',
      exportDelegate: exportDelegate,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
                foregroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              onPressed: null,
              child: const Text('TextButton'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
                foregroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              onPressed: null,
              child: const Text('ElevatedButton'),
            ),
            OutlinedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
                foregroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              onPressed: null,
              child: const Text('OutlinedButton'),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
                foregroundColor: WidgetStateProperty.all(Colors.green),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              onPressed: null,
              child: const Text('FilledButton'),
            ),
          ],
        ),
      ),
    ));

    pdf.addPage(await exportDelegate.exportToPdfPage('button style'));
  });

  tearDownAll(() async {
    final file = File('./test/output/widgets-form.pdf');
    file.writeAsBytesSync(await pdf.save());
  });
}
