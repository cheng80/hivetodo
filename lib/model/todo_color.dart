// todo_color.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';

/// TodoColor - 태그 색상 유틸리티 클래스 (static 메서드만 사용)
class TodoColor {
  /// 선택 가능한 전체 색상 목록 반환
  static List<Color> setColors() => [
        Colors.red,
        Colors.amber,
        Colors.purpleAccent,
        Colors.lightBlue,
        Colors.blue,
        Colors.deepOrange,
        Colors.pink,
        Colors.teal,
        Colors.indigoAccent,
        Colors.green,
      ];

  /// 인덱스에 해당하는 색상 반환 (범위 밖이면 회색)
  static Color colorOf(int index) => switch (index) {
        0 => Colors.red,
        1 => Colors.amber,
        2 => Colors.purpleAccent,
        3 => Colors.lightBlue,
        4 => Colors.blue,
        5 => Colors.deepOrange,
        6 => Colors.pink,
        7 => Colors.teal,
        8 => Colors.indigoAccent,
        9 => Colors.green,
        _ => const Color.fromRGBO(91, 91, 91, 1),
      };
}
