import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:json_util_desktop/widget/window_top.dart';
import 'package:oktoast/oktoast.dart';

class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        body: WindowBorder(
            color: Colors.blueGrey,
            width: 2,
            child: Column(children: [
              const WindowTopBox(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('返回'),
              )
            ])),
      ),
    ));
  }
}
