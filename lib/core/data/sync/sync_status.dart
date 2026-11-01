sealed class SyncStatus {
  const SyncStatus();
}

class SyncOffline extends SyncStatus {
  const SyncOffline({this.pending = 0});
  final int pending;
}

class SyncIdle extends SyncStatus {
  const SyncIdle({this.lastSyncedAtMs});
  final int? lastSyncedAtMs;
}

class SyncSyncing extends SyncStatus {
  const SyncSyncing({this.done = 0, this.total = 0});
  final int done;
  final int total;
}

class SyncPending extends SyncStatus {
  const SyncPending(this.count);
  final int count;
}

class SyncAttention extends SyncStatus {
  const SyncAttention(this.failed);
  final int failed;
}

class SyncAuthRequired extends SyncStatus {
  const SyncAuthRequired();
}

class SyncUpdateRequired extends SyncStatus {
  const SyncUpdateRequired();
}
