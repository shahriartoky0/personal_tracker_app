import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/data/remote/remote_gateway.dart';
import '../../core/domain/entities.dart';

/// Local file if present → cached/downloaded copy when online → placeholder.
Future<void> showProofViewer(BuildContext context, WidgetRef ref, Tx tx) async {
  final repo = ref.read(ledgerProvider);
  final localFile = await repo.localProofFile(tx.id);
  if (!context.mounted) return;
  final remote = SupabaseGateway(ref.read(supabaseProvider));
  final future = ref
      .read(proofServiceProvider)
      .load(localFile: localFile, remotePath: tx.receiptPath, remote: remote);
  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      child: FutureBuilder<List<int>?>(
        future: future,
        builder: (c, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          }
          final bytes = snap.data;
          if (bytes == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.cloud_off, size: 36),
                SizedBox(height: 8),
                Text('Proof available when online', textAlign: TextAlign.center),
              ]),
            );
          }
          return InteractiveViewer(child: Image.memory(Uint8List.fromList(bytes)));
        },
      ),
    ),
  );
}
