import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CustomWidget(
              text: 'Flutter is an open source framework by Google',
              isSelected: true,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomWidget extends StatelessWidget {
  /* Custom adaptive widget consisting of three elements
    Logic:
      - The first element with text. If the text is overflowing it acquires the `ellipsis` property
      - The second element contains a dotted line. If the screen shrinks or the length of the text
     in the first element increases. The second element shrinks and gives way to the first element.
     The minimum size is 10 pixels, when you reach 10 pixels, the dashed line is not visible.
      - The third element is unchanged.
   */

  static const double _minPixelMiddleElement = 10;
  static const double _elementHeight = 100;
  static const int _maxLines = 1;

  final String text;
  final bool isSelected;

  const CustomWidget({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool showDashed = true;
      double elementWidth = constraints.maxWidth / 3;
      double middleElementWidth = elementWidth;
      // Value 10 is added for the widget and method `TextOverflow.ellipsis` to work correctly
      double textWidth = _getTextWidth(context: context, text: text) + 10;

      // Reduce size the middle element
      if (elementWidth < textWidth) {
        middleElementWidth = elementWidth - (textWidth - elementWidth);

        if (middleElementWidth <= _minPixelMiddleElement) {
          // Set min size
          middleElementWidth = _minPixelMiddleElement;
          showDashed = false;
        }
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: _getBorderContainer(
            width: elementWidth,
            height: _elementHeight,
            child: Center(
                child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: _maxLines,
            )),
          )),
          _getBorderContainer(
            width: middleElementWidth,
            height: _elementHeight,
            child: showDashed
                ? CustomPaint(
                    painter: DashedLinePainter(),
                  )
                : const SizedBox.shrink(),
          ),
          _getBorderContainer(
              width: elementWidth,
              height: _elementHeight,
              child: Checkbox(value: isSelected, onChanged: null))
        ],
      );
    });
  }

  Container _getBorderContainer(
      {required double width, required double height, required Widget child}) {
    // The method returns the base border container

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: child,
    );
  }

  double _getTextWidth({required BuildContext context, required String text}) {
    // The method returns text width

    return (TextPainter(
            text: TextSpan(text: text),
            maxLines: _maxLines,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .width;
  }
}

class DashedLinePainter extends CustomPainter {
  // Custom painter with a dashed line

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    double dashWidth = 5, dashSpace = 5, startX = 0;
    double posY = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, posY), Offset(startX + dashWidth, posY), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
