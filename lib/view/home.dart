// home.dart
// 핵심 기능만 간단히 요약


import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hive_sample/model/todo.dart'; // Todo 데이터 모델
import 'package:flutter_hive_sample/model/todo_color.dart'; // Todo 색상 모델
import 'package:flutter_hive_sample/util/common_util.dart';
import 'package:flutter_hive_sample/view/todo_item.dart';
import 'package:flutter_hive_sample/view/sheets/todo_delete_sheet.dart';
import 'package:flutter_hive_sample/view/sheets/todo_edit_sheet.dart';
import 'package:flutter_hive_sample/vm/vm_handler.dart';
import 'package:flutter_hive_sample/vm/home_filter_notifier.dart';

/// TodoHome - Riverpod 기반 메인 화면
///
/// ConsumerStatefulWidget을 사용하여 ref 객체에 접근합니다.
/// ref를 통해 vmHandlerProvider를 구독(watch)하고 CRUD를 호출합니다.
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
    /// ─────────────────────────────────────────────────
    /// [ref.watch] - vmHandlerProvider를 구독합니다.
    /// ─────────────────────────────────────────────────
    /// 반환 타입: AsyncValue<List<Todo>>
    /// - AsyncData: 데이터 로드 완료 → todo 목록 표시
    /// - AsyncLoading: 로딩 중 → 로딩 인디케이터 표시
    /// - AsyncError: 에러 발생 → 에러 메시지 표시
    final AsyncValue<List<Todo>> todosAsync = ref.watch(vmHandlerProvider);

    /// ─────────────────────────────────────────────────
    /// [ref.listen] - 에러 발생 시 스낵바 표시 (1회성)
    /// ─────────────────────────────────────────────────
    /// ref.watch와 달리 위젯을 리빌드하지 않고,
    /// 상태 변화 시 1번만 실행되는 사이드이펙트에 적합합니다.
    ref.listen<AsyncValue<List<Todo>>>(vmHandlerProvider, (previous, next) {
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
      ref.read(vmHandlerProvider.notifier).filterTodos(
            tag: next.tag,
            keyword: next.keyword,
          );
    });

    Widget todoListView = todosAsync.when(
      /// [data] - 데이터 로드 완료 상태
      data: (todos) {
        if (todos.isEmpty) {
          return const Center(
            child: Text(
              "할 일이 없습니다.\n상단의 + 버튼으로 추가해 보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(115, 115, 115, 1),
                fontSize: 16,
              ),
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
                ref.read(vmHandlerProvider.notifier),
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
          children: [
            Text(
              '오류 발생: $error',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
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
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),

        /// ─────────────────────────────────────────────────
        /// [AppBar] - 일반 앱바 (상단 고정)
        /// ─────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
          title: ref.watch(searchModeProvider)
              ? _buildSearchField()
              : _buildTitleWithTapArea(),
          actions: [
            /// [검색 토글] - 검색 모드에서는 입력창에서 닫기 제공
            if (!ref.watch(searchModeProvider))
              IconButton(
                onPressed: _toggleSearchMode,
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
            /// [새로고침 버튼] - 수동으로 데이터를 새로고침합니다.
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _reloadData();
              },
              icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            ),

            /// [Todo 추가 버튼] - 새 Todo 생성 화면으로 이동합니다.
            IconButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showEditSheet();
              },
              icon: const Icon(
                Icons.add_box_outlined,
                color: Colors.white,
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
            _buildFilterBar(),
            Expanded(child: todoListView),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────────
  /// [_buildSearchField] - 앱바 검색 입력 필드
  /// ─────────────────────────────────────────────────
  Widget _buildSearchField() {
    final hasText = ref.watch(searchQueryProvider).trim().isNotEmpty;

    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: '검색',
        hintStyle:
            const TextStyle(color: Color.fromRGBO(120, 120, 120, 1)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            if (hasText) {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).setQuery('');
            } else {
              _toggleSearchMode();
            }
          },
          icon: Icon(
            hasText ? Icons.clear : Icons.close,
            color: Colors.black,
          ),
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }

  /// ─────────────────────────────────────────────────
  /// [_buildTitle] - 앱바 기본 타이틀
  /// ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return const Text(
      "TODO",
      style: TextStyle(
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontSize: 24,
      ),
    );
  }

  /// 타이틀 오른쪽 여백 전체를 검색 토글 영역으로 사용
  Widget _buildTitleWithTapArea() {
    return Row(
      children: [
        _buildTitle(),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleSearchMode,
            child: const SizedBox(height: 44),
          ),
        ),
      ],
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

  /// ─────────────────────────────────────────────────
  /// [_buildFilterBar] - 태그 필터 드롭다운
  /// ─────────────────────────────────────────────────
  Widget _buildFilterBar() {
    final items = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(
        value: null,
        child: Text('전체'),
      ),
      ...List.generate(
        10,
        (index) => DropdownMenuItem<int?>(
          value: index,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: TodoColor.colorOf(index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // Text('$index'),
            ],
          ),
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          dropdownColor: const Color.fromRGBO(26, 26, 26, 1),
          value: ref.watch(selectedTagProvider),
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items,
          onChanged: (value) {
            ref.read(selectedTagProvider.notifier).setTag(value);
          },
        ),
      ),
    );
  }

  
  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).setQuery(_searchController.text);
  }

  /// ─────────────────────────────────────────────────
  /// [_showEditSheet] - Todo 생성/수정 BottomSheet
  /// ─────────────────────────────────────────────────
  /// [매개변수]
  /// - todo: 수정할 기존 Todo (null이면 생성 모드)
  ///
  /// BottomSheet가 닫힐 때 반환된 Todo 객체를
  /// VMHandler를 통해 Hive에 저장하고 상태를 갱신합니다.
  Future<void> _showEditSheet({Todo? todo}) async {
    final result = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => TodoEditSheet(update: todo),
      isScrollControlled: true,
    );

    /// BottomSheet에서 Todo 객체가 반환된 경우에만 처리
    if (result != null) {
      final vmHandler = ref.read(vmHandlerProvider.notifier);

      if (todo == null) {
        /// 생성 모드: insertTodo() 호출
        await vmHandler.insertTodo(result);
      } else {
        /// 수정 모드: updateTodo() 호출
        await vmHandler.updateTodo(result);
      }
      // invalidateSelf()가 내부에서 호출되므로 추가 작업 불필요
    }
  }

  /// ─────────────────────────────────────────────────
  /// [_showDeleteSheet] - 삭제 옵션 BottomSheet
  /// ─────────────────────────────────────────────────
  /// "이 항목 삭제" / "전체 삭제" 2가지 옵션을 제공합니다.
  void _showDeleteSheet(BuildContext context, Todo todo, VMHandler vmHandler) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TodoDeleteSheet(
        onDeleteOne: () {
          vmHandler.deleteTodo(todo.no);
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
          vmHandler.deleteAllTodos();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// [_reloadData] - 수동 새로고침
  /// VMHandler의 reloadData()를 호출하여 DB에서 데이터를 다시 로드합니다.
  void _reloadData() {
    ref.read(vmHandlerProvider.notifier).reloadData();
  }
}
