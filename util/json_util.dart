
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'comm.dart';
import 'textspan_extension.dart';

///获取缩进空白符(windows平台上实测，不能使用/t这种标签，会显示成一个方格，所以使用两个空格作为替代)
String getDeepSpace(int deep) {
  var tab = StringBuffer();
  for (int i = 0; i < deep; i++) {
    tab.write("    ");
  }
  return tab.toString();
}

String space1() {
  return " ";
}

TextStyle getTextStyleByColor({required Color color}) {
  return TextStyle(color: color, fontSize: CommConst.textSize);
}

/// json的List对象或map对象转成TextSpan
/// [object] 要转换的目标对象（基本类型 num，string，bool），复杂类型（map，list）
/// [deep] 当前层级，决定缩进的层次, 如果是一个复杂类型（map，list）不是头和尾，
TextSpan getTextSpan(dynamic object, int deep, {bool isObject = false}) {
  TextSpan box = const TextSpan();

  var nextDeep = deep + 1; // 每次递归，层级都会+1

  if (object is Map) {
    if (object.isEmpty) {
      box += TextSpan(text: ' { }', style: getTextStyleByColor(color: Colors.black));
      return box;
    }

    if (isObject) {
      box += TextSpan(text: space1());
    }

    box += TextSpan(text: '{\n', style: getTextStyleByColor(color: Colors.black));

    List list = object.keys.toList();
    for (int i = 0; i < list.length; i++) {
      var k = list[i];
      var v = object[k];
      box += TextSpan(text: getDeepSpace(nextDeep));
      box += TextSpan(text: '"$k"', style: getTextStyleByColor(color: Colors.lightGreen));
      box += TextSpan(text: ':', style: getTextStyleByColor(color: Colors.black));
      box += getTextSpan(v, nextDeep, isObject: true);

      if (i < list.length - 1) {
        box += TextSpan(text: ',\n', style: getTextStyleByColor(color: Colors.black));
      }
    }

    if (isObject) {
      box += TextSpan(text: '\n${getDeepSpace(nextDeep - 1)}}', style: getTextStyleByColor(color: Colors.black));
    } else {
      box += TextSpan(text: '\n}', style: getTextStyleByColor(color: Colors.black));
    }

    return box;
  }

  if (object is List) {
    if (object.isEmpty) {
      box += TextSpan(text: ' [ ]', style: getTextStyleByColor(color: Colors.black));
      return box;
    }

    if (isObject) {
      box += TextSpan(text: space1());
    }

    box += TextSpan(text: '[\n', style: getTextStyleByColor(color: Colors.black));

    for (int i = 0; i < object.length; i++) {
      box += TextSpan(text: getDeepSpace(nextDeep));
      box += getTextSpan(object[i], nextDeep, isObject: true);

      if (i < object.length - 1) {
        box += TextSpan(text: ',\n', style: getTextStyleByColor(color: Colors.black));
      }
    }

    if (isObject) {
      box += TextSpan(text: '\n${getDeepSpace(nextDeep - 1)}}', style: getTextStyleByColor(color: Colors.black));
    } else {
      box += const TextSpan(text: '\n}', style: TextStyle(color: Colors.black));
    }

    return box;
  }

  if (object is String) {
    //为字符串时，需要添加双引号并返回当前内容
    box += TextSpan(text: ' "$object"', style: getTextStyleByColor(color: Colors.blue));
    return box;
  }

  // num下就只有int和double
  if (object is num) {
    box += TextSpan(text: ' $object', style: getTextStyleByColor(color: Colors.redAccent));
    return box;
  }

  if (object is bool) {
    box += TextSpan(text: ' $object', style: getTextStyleByColor(color: Colors.lightGreen));
    return box;
  }

  // num下就只有int和double
  box += TextSpan(text: 'null', style: getTextStyleByColor(color: Colors.cyan));
  return box;
}

/// 递归函数，将当前类型（复杂类型，list，map，或 诸如string，int这样的单纯类型） 转化成已格式化的json字符串，带缩进和换行
///
/// [object]  解析的对象
/// [deep]  递归的深度，用来获取缩进的空白长度
/// [isObject] 用来区分当前map或list是不是来自某个字段，则不用显示缩进。单纯的map或list需要添加缩进
String convert(dynamic object, int deep, {bool isObject = false}) {
  var buffer = StringBuffer();
  var nextDeep = deep + 1;

  if (object is String) {
    //为字符串时，需要添加双引号并返回当前内容
    buffer.write("\"$object\"");
    return buffer.toString();
  }
  if (object is num || object is bool) {
    //为数字或者布尔值时，返回当前内容
    buffer.write(object);
    return buffer.toString();
  }

  // 这段逻辑，如果按照阻断式的写法，那就是:
  if (object is Map) {
    var list = object.keys.toList();
    if (isObject) {
      buffer.write(space1());
    }
    buffer.write("{");
    if (list.isEmpty) {
      //当map为空，直接返回‘}’
      buffer.write("}");
    } else {
      buffer.write("\n");
      for (int i = 0; i < list.length; i++) {
        buffer.write("${getDeepSpace(nextDeep)}\"${list[i]}\":");
        buffer.write(convert(object[list[i]], nextDeep, isObject: true));
        if (i < list.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}}");
    }
    return buffer.toString();
  }

  if (object is List) {
    if (isObject) {
      buffer.write(space1());
    }
    buffer.write("[");
    if (object.isEmpty) {
      //当list为空，直接返回‘]’
      buffer.write("]");
    } else {
      buffer.write("\n");
      for (int i = 0; i < object.length; i++) {
        buffer.write(getDeepSpace(nextDeep));
        buffer.write(convert(object[i], nextDeep));
        if (i < object.length - 1) {
          buffer.write(",");
          buffer.write("\n");
        }
      }
      buffer.write("\n");
      buffer.write("${getDeepSpace(deep)}]");
    }

    return buffer.toString();
  }

  //如果对象为空，则返回null字符串
  buffer.write("null");
  return buffer.toString();
}
