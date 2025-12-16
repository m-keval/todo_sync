import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/constants.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/empty_todo_view.dart';
import '../widgets/offline_banner.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sync_status_bar.dart';
import '../widgets/todo_item.dart';
import 'add_todo_sheet.dart';
import 'login_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isConnected = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoBloc>().add(LoadTodos());
    });

    Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      final connected = !result.contains(ConnectivityResult.none);
      setState(() {
        isConnected = connected;
      });

      if (connected) {
        context.read<TodoBloc>().add(SyncOfflineTodos());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<TodoBloc>().add(SearchTodos(value));
  }

  void _onLogoutPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onFabPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTodoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () async {
              context.read<TodoBloc>().add(SyncOfflineTodos());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: false,
                  toolbarHeight: 80,
                  titleSpacing: 16,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 0,
                  title: Row(
                    children: [
                    Image.asset(
                    AppAssets.logo,
                    height: 35,
                    width: 35),
                      const SizedBox(width: 12),
                      Text(
                        'Todo Sync',
                        style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: _onLogoutPressed,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SearchBarWidget(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onClear: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                      ),
                      const SyncStatusBar(),
                      OfflineStatusBanner(isConnected: isConnected),
                    ],
                  ),
                ),
                if (state is TodoLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CupertinoActivityIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                else if (state is TodoLoaded)
                  if (state.todos.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAssets.logo,
                              width: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet!',
                              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return TodoItem(todo: state.todos[index]);
                          },
                          childCount: state.todos.length,
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _onFabPressed,
            icon: const Icon(Icons.add),
            label: const Text('Create task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              foregroundColor: theme.colorScheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
