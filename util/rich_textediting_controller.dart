import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_util_desktop/util/comm.dart';

import 'json_util.dart';

class RichTextEditingController extends TextEditingController {
  bool needRich = true;

  RichTextEditingController(this.needRich);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (!needRich) {
      return TextSpan(text: value.text, style: TextStyle(color: Colors.black, fontSize: style?.fontSize));
    }

    try {
      return getTextSpan(jsonDecode(value.text), 0);
    } catch (e) {
      return TextSpan(text: value.text, style: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold));
    }
  }
}
