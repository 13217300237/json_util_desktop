import 'package:flutter/cupertino.dart';

extension TextSpanHelper on TextSpan {
  TextSpan operator +(TextSpan textSpan) {
    return TextSpan(children: [this, textSpan]);
  }

  TextSpan appendString(String? text) {
    if (text == null) return this;
    return TextSpan(children: [this, TextSpan(text: text, style: style)]);
  }
}
