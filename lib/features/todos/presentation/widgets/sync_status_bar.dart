import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/todo_bloc.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({Key? key}) : super(key: key);

  String _formatSyncDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today ${DateFormat('hh:mm a').format(date)}';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('dd-MM-yyyy hh:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (previous, current) {
        if (previous is TodoLoaded && current is TodoLoaded) {
          return previous.lastSyncedAt != current.lastSyncedAt;
        }
        return current is TodoLoaded;
      },
      builder: (context, state) {
        if (state is TodoLoaded && state.lastSyncedAt != null) {
          return Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Last synced: ${_formatSyncDate(state.lastSyncedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
