// main.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/todo.dart';
import 'package:flutter_hive_sample/util/common_util.dart';
import 'package:flutter_hive_sample/view/home.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 앱의 메인 함수
void main() async {
  /// [Step 1] Hive를 Flutter 환경에 맞게 초기화합니다.
  await Hive.initFlutter();

  /// [Step 2] Todo 클래스의 TypeAdapter를 Hive에 등록합니다.
  Hive.registerAdapter(TodoAdapter());

  /// [Step 3] "todo" Box를 엽니다.
  await Hive.openBox<Todo>("todo");

  /// [Step 4] ProviderScope로 감싸서 Riverpod 상태관리를 활성화합니다.
  runApp(const ProviderScope(child: MyApp()));
}

/// ============================================================================
/// [MyApp] - 앱의 루트 위젯
/// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 디버그 배너 제거
      debugShowCheckedModeBanner: false,

      /// 최상위 Overlay 접근을 위한 navigatorKey 연결
      navigatorKey: rootNavigatorKey,

      /// 최상위 스낵바 표시를 위한 messengerKey 연결
      scaffoldMessengerKey: rootMessengerKey,

      /// Riverpod 방식의 메인 화면
      home: const TodoHome(),
    );
  }
}
