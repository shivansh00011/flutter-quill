import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

void main() {
  testWidgets('paragraph lineSpacing increases space between lines', (tester) async {
    final controller = QuillController.basic();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuillEditor.basic(
            controller: controller,
            config: QuillEditorConfig(
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  const TextStyle(fontSize: 20, color: Colors.black, height: 3.5),
                  HorizontalSpacing.zero,
                  VerticalSpacing.zero,
                  const VerticalSpacing(50, 50), // Large line spacing
                  null,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Add two lines of text
    controller.document = Document.fromDelta(
      Delta()
        ..insert('Line 1\n')
        ..insert('Line 2\n'),
    );
    await tester.pumpAndSettle();

    // Find all RichText widgets
    final richTexts = find.byType(RichText);
    final richTextWidgets = <RichText>[];
    richTexts.evaluate().forEach((element) {
      final widget = element.widget;
      if (widget is RichText) {
        richTextWidgets.add(widget);
      }
    });

    // Find the ones that contain 'Line 1' and 'Line 2'
    RenderBox? line1Box;
    RenderBox? line2Box;
    for (final element in richTexts.evaluate()) {
      final widget = element.widget as RichText;
      final text = widget.text.toPlainText();
      if (text.contains('Line 1')) {
        line1Box = element.renderObject as RenderBox;
      }
      if (text.contains('Line 2')) {
        line2Box = element.renderObject as RenderBox;
      }
    }
    expect(line1Box, isNotNull, reason: 'Line 1 should be found');
    expect(line2Box, isNotNull, reason: 'Line 2 should be found');

    final line1Offset = line1Box!.localToGlobal(Offset.zero).dy;
    final line2Offset = line2Box!.localToGlobal(Offset.zero).dy;
    final actualSpacing = line2Offset - line1Offset;
    // The spacing should be at least the font size (20) * height (3.5) = 70
    expect(actualSpacing, greaterThanOrEqualTo(70));
  });
} 