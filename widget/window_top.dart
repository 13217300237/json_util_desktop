
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Color _mainColor = Colors.blueGrey;

/// 顶部操作按钮
class WindowTopBox extends StatelessWidget {
  const WindowTopBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current;

    current = WindowTitleBarBox(
        child: Row(children: [
      Expanded(
          child: Container(
              color: _mainColor,
              child: MoveWindow(
                  child: Row(children: const [
                SizedBox(width: 20),
                Text(
                  'Json解析工具',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                )
              ])))),
      _WindowButtons()
    ]));

    return current;
  }
}

class _WindowButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      MinimizeWindowButton(),
      MaximizeWindowButton(),
      CloseWindowButton(),
    ]);
  }
}
