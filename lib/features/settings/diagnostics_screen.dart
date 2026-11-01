import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/data/db/database.dart';
import '../../core/data/sync/sync_status.dart';
import '../../core/ui/app_snackbar.dart';

final _outboxProvider = StreamProvider<List<OutboxRow>>(
  (ref) => ref.watch(outboxProvider).watchAll(),
);
final _conflictsProvider = StreamProvider<List<ConflictLogRow>>(
  (ref) =>
      ref.watch(dbProvider).select(ref.watch(dbProvider).conflictLog).watch(),
);

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  String _describe(SyncStatus s) => switch (s) {
    SyncOffline() => 'Offline — changes are saved on this device',
    SyncIdle(:final lastSyncedAtMs) =>
      lastSyncedAtMs == null
          ? 'Up to date'
          : 'Up to date · last synced ${DateTime.fromMillisecondsSinceEpoch(lastSyncedAtMs)}',
    SyncSyncing(:final done, :final total) => 'Syncing $done of $total',
    SyncPending(:final count) => '$count change(s) waiting to sync',
    SyncAttention(:final failed) => '$failed change(s) need attention',
    SyncAuthRequired() =>
      'Sign in again to continue syncing. Your data is safe on this device.',
    SyncUpdateRequired() =>
      'Please update the app. You can keep working offline.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(syncStatusProvider).valueOrNull ?? const SyncOffline();
    final ops = ref.watch(_outboxProvider).valueOrNull ?? const <OutboxRow>[];
    final conflicts =
        ref.watch(_conflictsProvider).valueOrNull ?? const <ConflictLogRow>[];
    final engine = ref.read(syncEngineProvider);
    final attention = ops
        .where((o) => o.status == 'failed' || o.status == 'blocked')
        .toList();
    final queued = ops
        .where((o) => o.status == 'pending' || o.status == 'in_flight')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync & diagnostics'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: engine.syncNow,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.sync),
                title: Text(_describe(status)),
                subtitle: Text(
                  '$queued queued · ${attention.length} need attention',
                ),
                trailing: FilledButton(
                  onPressed: engine.syncNow,
                  child: const Text('Sync now'),
                ),
              ),
            ),
            if (status is SyncAuthRequired)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Sign out and back in with the same account to resume syncing.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Needs attention',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (attention.isEmpty)
              const Text('Nothing needs attention.')
            else
              for (final o in attention)
                Card(
                  child: ListTile(
                    title: Text('${o.entity} · ${o.op}'),
                    subtitle: Text(o.lastError ?? o.status),
                    trailing: Wrap(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await engine.push.retry(o.seq);
                            engine.kick(immediate: true);
                          },
                          child: const Text('Retry'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (d) => AlertDialog(
                                title: const Text('Discard this change?'),
                                content: const Text(
                                  'The local row is reverted to its last synced version.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(d, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(d, true),
                                    child: const Text('Discard'),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) await engine.push.discard(o.seq);
                          },
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            Text('Conflict log', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (conflicts.isEmpty)
              const Text('No conflicts recorded.')
            else
              for (final c in conflicts.reversed.take(30))
                ListTile(
                  dense: true,
                  title: Text('${c.entity} · ${c.resolution}'),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(c.atMs).toString(),
                  ),
                ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Rebuild from server?'),
                    content: const Text(
                      'Replaces local data with the server copy. Only allowed when nothing is waiting to sync.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Rebuild'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                final done = await engine.rebuildFromServer();
                if (context.mounted) {
                  done
                      ? AppSnack.success(context, 'Rebuilt from server')
                      : AppSnack.error(
                          context,
                          'Unsynced changes exist — sync or export them first.',
                        );
                }
              },
              child: const Text('Rebuild from server'),
            ),
          ],
        ),
      ),
    );
  }
}
