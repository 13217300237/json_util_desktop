import 'dart:convert';

extension JSONHelper on String? {


  String get jsJSON {
    if (this == null) return 'ERROR: 内容为空';
    try {
      jsonDecode(this ?? '');
    } catch (e) {
      return 'ERROR: $e';
    }
    return '';
  }
}

extension StringExtension on String {
  //为String类扩展首字母大写方法
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
