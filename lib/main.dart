// main.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tagdo/model/tag.dart';
import 'package:tagdo/model/todo.dart';
import 'package:tagdo/util/common_util.dart';
import 'package:tagdo/view/home.dart';
import 'package:tagdo/vm/theme_notifier.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 앱의 메인 함수
void main() async {
  /// [Step 0] GetStorage 초기화 (테마 등 경량 설정 저장용)
  await GetStorage.init();

  /// [Step 1] Hive를 Flutter 환경에 맞게 초기화합니다.
  await Hive.initFlutter();

  /// [Step 2] Todo, Tag TypeAdapter 등록
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(TagAdapter());

  /// [Step 3] Hive Box 열기
  await Hive.openBox<Todo>("todo");
  await Hive.openBox<Tag>("tag");

  /// [Step 4] ProviderScope로 감싸서 Riverpod 상태관리를 활성화합니다.
  runApp(const ProviderScope(child: MyApp()));
}

/// ============================================================================
/// [MyApp] - 앱의 루트 위젯
/// ============================================================================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      /// 디버그 배너 제거
      debugShowCheckedModeBanner: false,

      /// 테마 모드 (라이트/다크/시스템)
      themeMode: themeMode,

      /// 라이트/다크 ThemeData (context.palette 동작에 필요)
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),

      /// 최상위 Overlay 접근을 위한 navigatorKey 연결
      navigatorKey: rootNavigatorKey,

      /// 최상위 스낵바 표시를 위한 messengerKey 연결
      scaffoldMessengerKey: rootMessengerKey,

      /// Riverpod 방식의 메인 화면
      home: const TodoHome(),
    );
  }
}
