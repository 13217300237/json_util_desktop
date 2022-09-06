import 'package:flutter/material.dart';
import 'package:json_util_desktop/widget/window_top.dart';
import 'package:oktoast/oktoast.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:json_util_desktop/widget/main_page.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1220, 600);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        body: WindowBorder(color: Colors.blueGrey, width: 2, child: Column(children: const [WindowTopBox(), MainPage()])),
      ),
    ));
  }
}


