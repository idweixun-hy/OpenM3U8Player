// copy from https://github.com/qqzhao/flutterDemos/blob/master/lib/home/base/fitText/wisdom_fit_text.dart
import 'package:flutter/material.dart';
import 'package:open_m3u8_player/util/text_size_cal.dart';

class FitTextBox extends StatefulWidget {
  TextStyle? textStyle;
  final String showText;
  final Widget fixedHeightHeaderWidget;
  final Widget fixedHeightBottomWidget;

  FitTextBox(
      {required this.showText,
        required this.fixedHeightHeaderWidget,
        required this.fixedHeightBottomWidget,
        this.textStyle});

  @override
  __FitTextBoxState createState() => __FitTextBoxState();
}

class __FitTextBoxState extends State<FitTextBox> {
  double? _realFontSize;
  bool _layoutReady = false;
  bool _needCenter = false;
  bool _needScroll = false;

  void _calculateAndSetFontSize(Size size) {
    print('size = $size');
    double retFontSize = TextSize.calculateFontSizeSync(
      size,
      widget.showText,
    );
    _realFontSize = retFontSize;
    if (_realFontSize! >= TextSize.maxFontSize) {
      _needCenter = true;
    } else {
      _needCenter = false;
    }
    if (_realFontSize! <= TextSize.minFontSize) {
      _needScroll = true;
    } else {
      _needScroll = false;
    }
    print('needCenter = $_needCenter');
    _layoutReady = true;

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(FitTextBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
    if (oldWidget.showText != widget.showText) {
      _layoutReady = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('__FitTextBoxState build');

    var headerWidget = widget.fixedHeightHeaderWidget;
    var bottomWidget = widget.fixedHeightBottomWidget;
    if (!_layoutReady) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          headerWidget,
          Expanded(
            child: Container(
              child: LayoutBuilder(builder: (context, constraints) {
                _calculateAndSetFontSize(
                    Size(constraints.maxWidth, constraints.maxHeight));
                return Container(
                  child: Text('empty'),
                );
              }),
            ),
          ),
          bottomWidget,
        ],
      );
    }

    Widget childWidget = Container(
      child: Center(
        child: Text(
          widget.showText,
          style: widget.textStyle ??
              TextStyle(
                fontSize: _realFontSize,
              ),
        ),
      ),
    );

    if (_needScroll) {
      childWidget = SingleChildScrollView(
        child: childWidget,
      );
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          headerWidget,
          _needCenter
              ? childWidget
              : Expanded(
            child: childWidget,
          ),
          bottomWidget,
        ],
      ),
    );
  }
}
