import 'package:flutter/material.dart';

/// 鼠标放置上去会显示提示框的组件，底层显示的子组件和 弹窗显示的组件都必传
/// 提示框的位置会跟随组件位置而变化
class HoverEventWidget extends StatefulWidget {
  final Widget showChild;
  final Widget floatWidget;
  final bool showDown; // 是否显示在原组件的下方

  const HoverEventWidget({Key? key, required this.showChild, required this.floatWidget, required this.showDown}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HoverEventWidgetState();
  }
}

class HoverEventWidgetState extends State<HoverEventWidget> {
  bool showTipBool = false; // true 窗口已弹出，false窗口未弹出
  OverlayEntry? overlay;
  final GlobalKey _keyGreen = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _keyGreen,
      hoverColor: Colors.white,
      highlightColor: Colors.white,
      splashColor: Colors.white,
      onHover: (bool value) {
        if (value == true) {
          showTipWidget(context);
        } else {
          dismissDialog();
        }
      },
      onTap: () {},
      child: widget.showChild,
    );
  }

  void dismissDialog() {
    overlay?.remove();
    showTipBool = false;
  }

  /// 让这个方法支持多次调用，如果已经显示了，再次调用显示，则不与反应
  void showTipWidget(BuildContext context) {
    if (showTipBool) {
      return;
    }

    showTipBool = true;

    final RenderBox box = _keyGreen.currentContext?.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);

    OverlayEntry overlay = OverlayEntry(builder: (_) {
      return Positioned(
        left: offset.dx,
        top: widget.showDown ? offset.dy + 30 : offset.dy - box.size.height - 30,
        child: widget.floatWidget,
      );
    });

    Overlay.of(context)?.insert(overlay);
    this.overlay = overlay;
  }
}
