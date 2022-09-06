import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'textspan_extension.dart';

import 'comm.dart';
import 'string_extension_json.dart';

class MapToDartTextSpanUtil {
  static TextSpan trans(Map map, {required String className, required bool needDecodeFunction}) {
    TextSpan ts = const TextSpan();

    try {
      // 类头
      ts += const TextSpan(text: 'class  ');

      ts += TextSpan(text: className, style: classNameStyle);

      ts += const TextSpan(text: ' {\n');

      // 成员属性区
      FieldParserTextSpanResult fieldParserResult = _fieldArea(map, needDecodeFunction);

      ts += fieldParserResult.fields;

      // 构造函数区
      ts += _constructorFunctionArea(map, className);

      // fromJson函数
      ts += _fromJsonFunctionArea(map, className);

      // toJson函数区
      ts += _toJsonFunctionArea(map);

      if (needDecodeFunction) {
        // decode函数
        ts += _decodeFunctionArea(map, className);
      }

      ts += const TextSpan(text: '\n}\n\n');

      for (var e in fieldParserResult.clzs) {
        ts += e;
      }
    } catch (e) {
      rethrow;
    }

    return ts;
  }

  /// 判定key是否合法，
  /// 返回值，true 合法 ，false非法
  static bool _judgeIncorrectKey(dynamic key) {
    // 1. 必须是非空字符串
    if (key.runtimeType != String) {
      debugPrint('key $key 不是非空字符串，判定非法');
      return false;
    }

    // 2. 以字母开头, 3. 只能由字母，数字，下划线组成
    String temp = key as String;
    if (!RegExp('^[a-zA-Z][a-zA-Z0-9_]*\$').hasMatch(temp)) {
      debugPrint('key $key 不符合 字母开头并且只能由字母，数字，下划线组成，判定非法');
      return false;
    }

    return true;
  }

  /// 检查一个list的内容是否合法
  static dynamic getListItemType(List list) {
    if (list.isEmpty) {
      return Null;
    }

    if (list.length == 1) {
      return list[0].runtimeType;
    }

    List runtimeTypeList = list.map((e) => e.runtimeType).toList();
    dynamic current = list[0].runtimeType;

    for (var i = 1; i < runtimeTypeList.length; i++) {
      if (current != runtimeTypeList[i]) {
        current = dynamic;
        break;
      }
    }
    return current;
  }

  static FieldParserTextSpanResult _fieldArea(Map map, bool needDecodeFunction) {
    TextSpan ts = const TextSpan();

    List<TextSpan> clzs = [];

    List keyList = map.keys.toList();
    for (var key in keyList) {
      dynamic value = map[key];

      // 先排除异常情况
      // 如果key不是非空字符串，或者它不是以字母开头由字母和数字构成，则判定key格式错误
      if (!_judgeIncorrectKey(key)) {
        throw '不合法的key $key'; // 如果是非法，那就抛出异常
      } else if (value is Map) {
        // 1. 判断是否是字母开头，如果不是，则
        // 2. 再把首字母转成大写
        String keyCapitalize = (key as String).capitalize();
        // 则应该按照一个对象来设置属性，对象类名要转化首字母大小写，如果是不规范的key，则认定为转化失败
        ts += TextSpan(text: '$_baseSpaces$keyCapitalize? ');

        ts += TextSpan(text: key, style: fieldStyle);
        ts += const TextSpan(text: ';\n');

        // 并且取出map的值，然后将它按照一个新的 map来构建一个class
        clzs.add(trans(value, className: keyCapitalize, needDecodeFunction: needDecodeFunction));
      } else if (value is List) {
        dynamic listItemType = getListItemType(value);

        // 如果是 map对象，那就把这个对象命名为 key的首字母大写变换形态
        if ('$listItemType'.contains('_InternalLinkedHashMap')) {
          listItemType = (key as String).capitalize();

          var firstItem = (value)[0];
          clzs.add(trans(firstItem as Map, className: listItemType, needDecodeFunction: needDecodeFunction));
        }

        ts += TextSpan(text: '${_baseSpaces}List<$listItemType>? ');

        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      } else if (value is String) {
        ts += const TextSpan(text: '${_baseSpaces}String? ');
        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      } else if (value is bool) {
        ts += const TextSpan(text: '${_baseSpaces}bool? ');
        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      } else if (value is double) {
        ts += const TextSpan(text: '${_baseSpaces}double? ');
        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      } else if (value is int) {
        ts += const TextSpan(text: '${_baseSpaces}int? ');
        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      } else {
        ts += const TextSpan(text: '${_baseSpaces}dynamic ');
        ts += TextSpan(text: '$key', style: fieldStyle);
        ts += const TextSpan(text: ';\n');
      }
    }

    return FieldParserTextSpanResult(ts, clzs);
  }

  static const String _baseSpaces = '      ';

  static TextSpan _constructorFunctionArea(Map map, String className) {
    TextSpan ts = const TextSpan();

    ts += TextSpan(text: '\n$_baseSpaces$className({\n');

    // 中间对属性进行遍历
    List<String> keyStrList = map.keys.toList().map((e) => '$e').toList();
    for (var e in keyStrList) {
      ts += const TextSpan(text: '$_baseSpaces  ');

      ts += TextSpan(text: e, style: fieldStyle);
      ts += const TextSpan(text: ',\n');
    }

    ts += const TextSpan(text: '$_baseSpaces});\n');

    return ts;
  }

  static TextSpan _fromJsonFunctionArea(Map map, String className) {
    TextSpan ts = const TextSpan();

    ts += const TextSpan(text: '\n$_baseSpaces');

    ts += TextSpan(text: className, style: classNameStyle);

    ts += const TextSpan(text: '.fromJson(Map<String, dynamic> json) {\n');

    map.keys.toList().forEach((key) {
      // 获得value的类型
      var value = map[key];

      if (value is Map) {
        ts += const TextSpan(text: '$_baseSpaces  ');

        ts += TextSpan(text: '$key', style: fieldStyle);

        ts += TextSpan(text: ' = json[\'$key\'] != null ? ${(key as String).capitalize()}.fromJson(json[\'map\']) : null;\n');
      } else if (value is List) {
        var type = getListItemType(value);
        if ('$type'.contains('_InternalLinkedHashMap<String, dynamic>')) {
          type = 'Map<String, dynamic>';
          String keyCapitalize = (key as String).capitalize();

          ts += TextSpan(text: ''' 
        if (json['$key'] != null) {
            ''');
          ts += TextSpan(text: key, style: fieldStyle);
          ts += TextSpan(text: ''' = <$keyCapitalize>[];
            json['$keyCapitalize'].forEach((v) {
              ''');
          ts += TextSpan(text: key, style: fieldStyle);
          ts += TextSpan(text: '''!.add($keyCapitalize.fromJson(v));
            });
        }
          \n''');
        } else {
          ts += const TextSpan(text: '$_baseSpaces  ');

          ts += TextSpan(text: '$key', style: fieldStyle);

          ts += TextSpan(text: ' = json[\'$key\'].cast<$type>();\n');
        }
      } else {
        ts += const TextSpan(text: '$_baseSpaces  ');

        ts += TextSpan(text: '$key', style: fieldStyle);

        ts += TextSpan(text: ' = json[\'$key\'];\n');
      }
    });

    ts += const TextSpan(text: '$_baseSpaces}\n');
    return ts;
  }

  static TextSpan _toJsonFunctionArea(Map map) {
    TextSpan ts = const TextSpan();
    ts += const TextSpan(text: '\n${_baseSpaces}Map<String, dynamic> toJson() {\n');

    ts += const TextSpan(text: '$_baseSpaces  final Map<String, dynamic> data = <String, dynamic>{};\n');

    map.keys.toList().forEach((key) {
      // 获得value的类型
      var value = map[key];

      if (value is Map) {
        ts += const TextSpan(text: '''\n
        if (''');

        ts += TextSpan(text: '$key', style: fieldStyle);

        ts += TextSpan(text: '''!= null) {
           data['$key'] = ''');

        ts += TextSpan(text: '$key', style: fieldStyle);

        ts += const TextSpan(text: '''!.toJson();
        }
         ''');
      } else if (value is List) {
        ts += const TextSpan(text: '\n$_baseSpaces  if (');

        ts += TextSpan(text: key, style: fieldStyle);

        ts += TextSpan(text: ''' != null) {
          data['$key'] = ''');

        ts += TextSpan(text: key, style: fieldStyle);

        ts += const TextSpan(text: '''!.map((v) => v.toJson()).toList();
        }''');
      } else {
        ts += TextSpan(text: '$_baseSpaces  data[\'$key\'] = ');

        ts += TextSpan(text: '$key', style: fieldStyle);

        ts += const TextSpan(text: ';\n');
      }
    });

    ts += const TextSpan(text: '\n$_baseSpaces  return data;\n\n');

    ts += const TextSpan(text: '$_baseSpaces}\n');

    return ts;
  }

  static TextSpan _decodeFunctionArea(Map map, String className) {
    TextSpan ts = const TextSpan();

    ts += const TextSpan(text: '''\n
      static ''');

    ts += TextSpan(text: className, style: classNameStyle);

    ts += const TextSpan(text: ''' decode(Map<String, dynamic> json) {
       return ''');

    ts += TextSpan(text: className, style: classNameStyle);

    ts += const TextSpan(text: '''.fromJson(json);
      }
    ''');

    return ts;
  }
}
