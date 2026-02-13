// home.dart
// 핵심 기능만 간단히 요약

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tagdo/model/todo.dart'; // Todo 데이터 모델
import 'package:tagdo/theme/app_colors.dart';
import 'package:tagdo/theme/config_ui.dart';
import 'package:tagdo/util/app_storage.dart';
import 'package:tagdo/util/common_util.dart';
import 'package:tagdo/view/todo_item.dart';
import 'package:tagdo/view/sheets/todo_delete_sheet.dart';
import 'package:tagdo/view/sheets/todo_edit_sheet.dart';
import 'package:tagdo/view/app_drawer.dart';
import 'package:tagdo/view/home_widgets.dart';
import 'package:tagdo/vm/todo_list_notifier.dart';
import 'package:tagdo/vm/home_filter_notifier.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _drawerKey = GlobalKey();
  final _tagManageKey = GlobalKey();
  final _searchKey = GlobalKey();
  final _addKey = GlobalKey();
  final _filterKey = GlobalKey();
  final _firstTodoKey = GlobalKey();
  bool _tutorialInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tutorialInitialized) {
      _tutorialInitialized = true;
      _initTutorial(context);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    try {
      ShowcaseView.get().unregister();
    } catch (_) {}
    super.dispose();
  }

  void _initTutorial(BuildContext context) {
    final p = context.palette;
    final scaffoldKey = _scaffoldKey;
    ShowcaseView.register(
      enableShowcase: !AppStorage.getTutorialCompleted(),
      onDismiss: (_) => AppStorage.setTutorialCompleted(),
      onFinish: () => AppStorage.setTutorialCompleted(),
      onComplete: (index, key) {
        /// 태그 관리(1번) → 검색(2번) 전환 시 Drawer 닫기
        if (index == 1) scaffoldKey.currentState?.closeDrawer();
      },
      globalTooltipActionConfig: TooltipActionConfig(
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 12,
        position: TooltipActionPosition.inside,
        gapBetweenContentAndAction: 16,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'tutorial_skip'.tr(),
          onTap: () => ShowcaseView.get().dismiss(),
          backgroundColor: p.chipUnselectedBg,
          textStyle: TextStyle(color: p.chipUnselectedText, fontSize: 14),
          borderRadius: ConfigUI.chipRadius,
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'tutorial_next'.tr(),
          backgroundColor: p.chipSelectedBg,
          textStyle: TextStyle(color: p.chipSelectedText, fontSize: 14),
          borderRadius: ConfigUI.chipRadius,
        ),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 튜토리얼용 할 일 생성 (시스템 언어에 맞게 context.tr() 사용)
      if (!AppStorage.getTutorialTodoCreated() &&
          AppStorage.getFirstLaunchDate() != null) {
        final todos = await ref.read(todoListProvider.future);
        if (todos.isEmpty && mounted) {
          final content = 'tutorialTodoContent'.tr();
          await ref.read(todoListProvider.notifier).createTutorialTodoIfNeeded(content);
        }
      }
      if (!AppStorage.getTutorialCompleted() && mounted) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        final todos = await ref.read(todoListProvider.future);
        final keys = [
          _tagManageKey,
          _drawerKey,
          _searchKey,
          _addKey,
          _filterKey,
          if (todos.isNotEmpty) _firstTodoKey,
        ];
        _scaffoldKey.currentState?.openDrawer();
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        ShowcaseView.get().startShowCase(keys);
      }
    });
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
          message: '${'errorOccurred'.tr()}: ${next.error}',
          action: SnackBarAction(label: 'retry'.tr(), onPressed: () => _reloadData()),
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
      ref
          .read(todoListProvider.notifier)
          .filterTodos(
            tag: next.tag,
            keyword: next.keyword,
            isCheck: isCheck,
            hasDueDate: next.hasDueDate,
          );
    });

    Widget todoListView = todosAsync.when(
      /// [data] - 데이터 로드 완료 상태
      data: (todos) {
        if (todos.isEmpty) {
          return Center(
            child: Text(
              'emptyTodoHint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textSecondary, fontSize: 16),
            ),
          );
        }
        return ReorderableListView.builder(
          itemCount: todos.length,
          onReorder: (oldIndex, newIndex) {
            /// ReorderableListView는 아래로 이동 시 newIndex가 +1 됨
            if (newIndex > oldIndex) newIndex--;
            HapticFeedback.mediumImpact();
            ref.read(todoListProvider.notifier).reorder(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
            /// 드래그 중인 아이템에 그림자 효과 (ConfigUI)
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Material(
                elevation: ConfigUI.elevationDragProxy,
                color: Colors.transparent,
                child: child,
              ),
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final todo = todos[index];
            final item = TodoItem(
              key: ValueKey(todo.no),
              todo: todo,
              index: index,
              onTap: () => _showEditSheet(todo: todo),
              onLongPress: () => _showDeleteSheet(
                context,
                todo,
                ref.read(todoListProvider.notifier),
              ),
            );
            if (index == 0) {
              return KeyedSubtree(
                key: ValueKey(todo.no),
                child: Showcase(
                  key: _firstTodoKey,
                  description: 'tutorial_step_6'.tr(),
                  tooltipBackgroundColor: p.sheetBackground,
                  textColor: p.textOnSheet,
                  tooltipBorderRadius: ConfigUI.cardRadius,
                  child: item,
                ),
              );
            }
            return item;
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
            Text('${'errorOccurred'.tr()}: $error', style: TextStyle(color: p.textPrimary)),
            ElevatedButton(
              onPressed: () => _reloadData(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      /// 빈 영역 탭 시 키보드 숨기기
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: p.background,

        /// [Drawer] - 설정 사이드 메뉴
        drawer: AppDrawer(
          onTutorialReplay: _restartTutorial,
          tagManageShowcaseKey: _tagManageKey,
        ),

        /// ─────────────────────────────────────────────────
        /// [AppBar] - 일반 앱바 (상단 고정)
        /// ─────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: p.background,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: p.icon),
          leading: Showcase(
            key: _drawerKey,
            description: 'tutorial_step_2'.tr(),
            tooltipBackgroundColor: p.sheetBackground,
            textColor: p.textOnSheet,
            tooltipBorderRadius: ConfigUI.cardRadius,
            child: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: p.icon, size: 28),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          title: ref.watch(searchModeProvider)
              ? HomeSearchField(
                  controller: _searchController,
                  onToggleSearch: _toggleSearchMode,
                )
              : HomeTitleBar(onToggleSearch: _toggleSearchMode),
          actions: [
            /// [검색 토글] - 검색 모드에서는 입력창에서 닫기 제공
            if (!ref.watch(searchModeProvider))
              Showcase(
                key: _searchKey,
                description: 'tutorial_step_3'.tr(),
                tooltipBackgroundColor: p.sheetBackground,
                textColor: p.textOnSheet,
                tooltipBorderRadius: ConfigUI.cardRadius,
                child: IconButton(
                  onPressed: _toggleSearchMode,
                  icon: Icon(Icons.search, color: p.icon, size: 28),
                ),
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
            Showcase(
              key: _addKey,
              description: 'tutorial_step_4'.tr(),
              tooltipBackgroundColor: p.sheetBackground,
              textColor: p.textOnSheet,
              tooltipBorderRadius: ConfigUI.cardRadius,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showEditSheet();
                },
                icon: Icon(Icons.add_box_outlined, color: p.icon, size: 32),
              ),
            ),
          ],
        ),

        /// ─────────────────────────────────────────────────
        /// [body] - 필터 + Todo 목록
        /// ─────────────────────────────────────────────────
        body: Column(
          children: [
            Divider(color: p.divider, height: 1),
            HomeFilterRow(filterShowcaseKey: _filterKey),
            Divider(color: p.divider, height: 1),
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
    final p = context.palette;
    final result = await showModalBottomSheet<Todo>(
      context: context,
      backgroundColor: p.sheetBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ConfigUI.radiusSheet),
        ),
      ),
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
  void _showDeleteSheet(
    BuildContext context,
    Todo todo,
    TodoListNotifier todoNotifier,
  ) {
    final p = context.palette;

    /// 하이라이트 ON
    ref.read(highlightedTodoProvider.notifier).highlight(todo.no);

    showModalBottomSheet(
      context: context,
      backgroundColor: p.sheetBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ConfigUI.radiusSheet),
        ),
      ),
      builder: (context) => TodoDeleteSheet(
        onDeleteOne: () {
          todoNotifier.deleteTodo(todo.no);
          Navigator.of(context).pop();
        },
        onDeleteChecked: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: 'deleteCompletedTitle'.tr(),
            message: 'deleteCompletedMessage'.tr(),
            confirmLabel: 'delete'.tr(),
            confirmColor: Colors.red,
          );
          if (!context.mounted) return;
          if (!confirmed) return;
          todoNotifier.deleteCheckedTodos();
          Navigator.of(context).pop();
        },
        onDeleteAll: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: 'deleteAllTitle'.tr(),
            message: 'deleteAllMessage'.tr(),
            confirmLabel: 'delete'.tr(),
            confirmColor: Colors.red,
          );
          if (!context.mounted) return;
          if (!confirmed) return;
          todoNotifier.deleteAllTodos();
          Navigator.of(context).pop();
        },
      ),
    ).whenComplete(() {
      /// 시트 닫힘 → 하이라이트 OFF
      ref.read(highlightedTodoProvider.notifier).highlight(null);
    });
  }

  /// [_reloadData] - 수동 새로고침
  void _reloadData() {
    ref.read(todoListProvider.notifier).reloadData();
  }

  /// [_restartTutorial] - Drawer "튜토리얼 다시 보기" 호출 시
  void _restartTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final todos = await ref.read(todoListProvider.future);
      final keys = [
        _tagManageKey,
        _drawerKey,
        _searchKey,
        _addKey,
        _filterKey,
        if (todos.isNotEmpty) _firstTodoKey,
      ];
      _scaffoldKey.currentState?.openDrawer();
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      final sv = ShowcaseView.get();
      sv.enableShowcase = true;
      sv.startShowCase(keys);
    });
  }
}
