import 'package:flutter/material.dart';
import 'package:json_util_desktop/util/string_extension_json.dart';

import '../util/comm.dart';

class JsonInputAreaWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool readOnly;
  final int lineCount;
  final Function? actionWhenEditing;
  final Color borderColor;
  final ScrollController scrollController;
  final bool showClear;

  const JsonInputAreaWidget({
    super.key,
    required this.controller,
    required this.readOnly,
    this.lineCount = 10,
    this.actionWhenEditing,
    this.borderColor = Colors.green,
    this.showClear = false,
    required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() {
    return JsonInputAreaWidgetState();
  }
}

class JsonInputAreaWidgetState extends State<JsonInputAreaWidget> {
  String _text = '';
  String verifyRes = '';

  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (!_node.hasFocus) {
        debugPrint('焦点丢失');
        widget.actionWhenEditing?.call();
      }
    });
  }

  Widget jsonInputArea() {
    return TextField(
      scrollController: widget.scrollController,
      focusNode: _node,
      readOnly: widget.readOnly,
      controller: widget.controller,
      cursorColor: Colors.green,
      minLines: widget.lineCount,
      maxLines: widget.lineCount,
      onChanged: (text) {
        _text = text;
        verifyRes = _text.jsJSON;
        widget.actionWhenEditing?.call();
      },
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: widget.borderColor, width: 2),
        ),
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Stack(children: [
          jsonInputArea(),
          if (widget.showClear) ...[
            Positioned(
              top: 10,
              right: 80,
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.actionWhenEditing?.call();
                },
                child: const Text('清空'),
              ),
            ),
            Positioned(
              top: 10,
              right: 20,
              child: getTipWidget(showTip: '提示', toastTip: 'json格式必须正确，而且只能转化map，不能转化数组',showDown: true),
            )
          ]
        ]));
  }
}
