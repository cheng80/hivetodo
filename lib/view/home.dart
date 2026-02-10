// home.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/todo.dart'; // Todo 데이터 모델
import 'package:flutter_hive_sample/theme/app_colors.dart';
import 'package:flutter_hive_sample/util/common_util.dart';
import 'package:flutter_hive_sample/view/todo_item.dart';
import 'package:flutter_hive_sample/view/sheets/todo_delete_sheet.dart';
import 'package:flutter_hive_sample/view/sheets/todo_edit_sheet.dart';
import 'package:flutter_hive_sample/view/app_drawer.dart';
import 'package:flutter_hive_sample/view/home_widgets.dart';
import 'package:flutter_hive_sample/vm/todo_list_notifier.dart';
import 'package:flutter_hive_sample/vm/home_filter_notifier.dart';

/// TodoHome - Riverpod 기반 메인 화면
///
/// ConsumerStatefulWidget을 사용하여 ref 객체에 접근합니다.
/// ref를 통해 todoListProvider를 구독(watch)하고 CRUD를 호출합니다.
class TodoHome extends ConsumerStatefulWidget {
  const TodoHome({super.key});

  @override
  ConsumerState<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends ConsumerState<TodoHome> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    /// ─────────────────────────────────────────────────
    /// [ref.watch] - todoListProvider를 구독합니다.
    /// ─────────────────────────────────────────────────
    final AsyncValue<List<Todo>> todosAsync = ref.watch(todoListProvider);

    /// ─────────────────────────────────────────────────
    /// [ref.listen] - 에러 발생 시 스낵바 표시 (1회성)
    /// ─────────────────────────────────────────────────
    ref.listen<AsyncValue<List<Todo>>>(todoListProvider, (previous, next) {
      if (next is AsyncError) {
        showCommonSnackBar(
          context,
          message: '오류 발생: ${next.error}',
          action: SnackBarAction(
            label: '재시도',
            onPressed: () => _reloadData(),
          ),
        );
      }
    });

    ref.listen<FilterState>(filterStateProvider, (previous, next) {
      /// TodoStatus → bool? 변환
      final bool? isCheck = switch (next.status) {
        TodoStatus.checked => true,
        TodoStatus.unchecked => false,
        TodoStatus.all => null,
      };
      ref.read(todoListProvider.notifier).filterTodos(
            tag: next.tag,
            keyword: next.keyword,
            isCheck: isCheck,
          );
    });

    Widget todoListView = todosAsync.when(
      /// [data] - 데이터 로드 완료 상태
      data: (todos) {
        if (todos.isEmpty) {
          return Center(
            child: Text(
              "할 일이 없습니다.\n상단의 + 버튼으로 추가해 보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textSecondary, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoItem(
              todo: todo,
              onTap: () => _showEditSheet(todo: todo),
              onLongPress: () => _showDeleteSheet(
                context,
                todo,
                ref.read(todoListProvider.notifier),
              ),
            );
          },
        );
      },

      /// [loading] - 로딩 상태
      loading: () => const Center(child: CircularProgressIndicator()),

      /// [error] - 에러 상태
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            Text(
              '오류 발생: $error',
              style: TextStyle(color: p.textPrimary),
            ),
            ElevatedButton(
              onPressed: () => _reloadData(),
              child: const Text('재시도'),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      /// 빈 영역 탭 시 키보드 숨기기
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: p.background,

        /// [Drawer] - 설정 사이드 메뉴
        drawer: const AppDrawer(),

        /// ─────────────────────────────────────────────────
        /// [AppBar] - 일반 앱바 (상단 고정)
        /// ─────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: p.background,
          iconTheme: IconThemeData(color: p.icon),
          title: ref.watch(searchModeProvider)
              ? HomeSearchField(
                  controller: _searchController,
                  onToggleSearch: _toggleSearchMode,
                )
              : HomeTitleBar(onToggleSearch: _toggleSearchMode),
          actions: [
            /// [검색 토글] - 검색 모드에서는 입력창에서 닫기 제공
            if (!ref.watch(searchModeProvider))
              IconButton(
                onPressed: _toggleSearchMode,
                icon: Icon(Icons.search, color: p.icon, size: 28),
              ),
            /// [새로고침 버튼] - 수동으로 데이터를 새로고침합니다.
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _reloadData();
              },
              icon: Icon(Icons.refresh, color: p.icon, size: 28),
            ),

            /// [Todo 추가 버튼] - 새 Todo 생성 화면으로 이동합니다.
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showEditSheet();
              },
              icon: Icon(
                Icons.add_box_outlined,
                color: p.icon,
                size: 32,
              ),
            ),
          ],
        ),

        /// ─────────────────────────────────────────────────
        /// [body] - 필터 + Todo 목록
        /// ─────────────────────────────────────────────────
        body: Column(
          children: [
            const HomeFilterRow(),
            Expanded(child: todoListView),
          ],
        ),
      ),
    );
  }

  void _toggleSearchMode() {
    HapticFeedback.mediumImpact();
    final isSearchMode = ref.read(searchModeProvider);
    if (isSearchMode) {
      _searchController.clear();
      ref.read(searchQueryProvider.notifier).setQuery('');
    }
    ref.read(searchModeProvider.notifier).setMode(!isSearchMode);
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).setQuery(_searchController.text);
  }

  /// ─────────────────────────────────────────────────
  /// [_showEditSheet] - Todo 생성/수정 BottomSheet
  /// ─────────────────────────────────────────────────
  Future<void> _showEditSheet({Todo? todo}) async {
    final result = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => TodoEditSheet(update: todo),
      isScrollControlled: true,
    );

    /// BottomSheet에서 Todo 객체가 반환된 경우에만 처리
    if (result != null) {
      final todoNotifier = ref.read(todoListProvider.notifier);

      if (todo == null) {
        /// 생성 모드: insertTodo() 호출
        await todoNotifier.insertTodo(result);
      } else {
        /// 수정 모드: updateTodo() 호출
        await todoNotifier.updateTodo(result);
      }
    }
  }

  /// ─────────────────────────────────────────────────
  /// [_showDeleteSheet] - 삭제 옵션 BottomSheet
  /// ─────────────────────────────────────────────────
  void _showDeleteSheet(BuildContext context, Todo todo, TodoListNotifier todoNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TodoDeleteSheet(
        onDeleteOne: () {
          todoNotifier.deleteTodo(todo.no);
          Navigator.of(context).pop();
        },
        onDeleteAll: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: '전체 삭제',
            message: '정말 삭제하시겠습니까?',
            confirmLabel: '삭제',
            confirmColor: Colors.red,
          );
          if (!context.mounted) {
            return;
          }
          if (!confirmed) {
            return;
          }
          todoNotifier.deleteAllTodos();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// [_reloadData] - 수동 새로고침
  void _reloadData() {
    ref.read(todoListProvider.notifier).reloadData();
  }
}
