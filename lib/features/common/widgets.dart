import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/domain/calculators.dart';
import '../../core/domain/entities.dart';
import '../../core/domain/local_date.dart';
import '../../core/domain/money.dart';
import '../../core/ui/motion.dart';

String two(int n) => n.toString().padLeft(2, '0');

String formatDateTimeLocal(int ms, String tz) {
  final z = instantToZonedLocal(ms, tz);
  return '${z.year}-${two(z.month)}-${two(z.day)} ${two(z.hour)}:${two(z.minute)}';
}

class MoneyText extends StatelessWidget {
  const MoneyText(this.minor, {super.key, this.size, this.color, this.showSign = false});
  final int minor;
  final double? size;
  final Color? color;
  final bool showSign;
  @override
  Widget build(BuildContext context) =>
      Text(formatMoney(minor, showSign: showSign), style: moneyStyle(context, size: size, color: color));
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
                ?trailing,
              ]),
              const SizedBox(height: Tokens.s12),
              child,
            ],
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key, this.icon = Icons.inbox_outlined, this.title, this.actionLabel, this.onAction});
  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          LottieView(LottieAsset.empty, size: 120, fallback: icon),
          const SizedBox(height: 16),
          if (title != null) Text(title!, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          if (title != null) const SizedBox(height: 4),
          Text(message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ]),
      ),
    );
  }
}

/// "Today", "Yesterday", or "Mon, 3 Nov" for day-group headers.
String friendlyDay(LocalDate d, LocalDate today) {
  if (d == today) return 'Today';
  if (d == today.addDays(-1)) return 'Yesterday';
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final y = d.year == today.year ? '' : ' ${d.year}';
  return '${wd[d.weekday - 1]}, ${d.day} ${mo[d.month - 1]}$y';
}

String formatTimeLocal(int ms, String tz) {
  final z = instantToZonedLocal(ms, tz);
  return '${two(z.hour)}:${two(z.minute)}';
}

/// One transaction row. Sign + icon + text carry meaning (never colour alone);
/// a labelled cloud icon marks rows waiting to sync.
class TxTile extends StatelessWidget {
  const TxTile({
    super.key,
    required this.tx,
    required this.categories,
    required this.accounts,
    required this.tz,
    this.onTap,
    this.payeeNames = const {},
    this.timeOnly = false,
  });
  final Map<String, String> payeeNames;
  final Tx tx;
  final Map<String, Category> categories;
  final Map<String, Account> accounts;
  final String tz;
  final VoidCallback? onTap;
  final bool timeOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final viz = VizColors.of(context);
    final effect = TransactionCalculator.balanceEffect(tx);
    final isTransfer = tx.type == TxType.transfer || tx.type == TxType.personTransfer;
    final title = switch (tx.type) {
      TxType.transfer => tx.direction == TransferDirection.outbound ? 'Transfer out' : 'Transfer in',
      TxType.personTransfer => tx.direction == TransferDirection.outbound
          ? 'Sent to ${payeeNames[tx.payeeId] ?? 'person'}'
          : 'Received from ${payeeNames[tx.payeeId] ?? 'person'}',
      _ => categories[tx.categoryId]?.name ?? 'Uncategorised',
    };
    final when = timeOnly ? formatTimeLocal(tx.occurredAtMs, tz) : formatDateTimeLocal(tx.occurredAtMs, tz);
    final subtitle = [
      accounts[tx.accountId]?.name ?? '',
      if ((tx.merchant ?? '').isNotEmpty) tx.merchant!,
      when,
    ].where((x) => x.isNotEmpty).join(' · ');
    final amountColor = tx.type == TxType.income ? viz.good : scheme.onSurface;
    final icon = isTransfer
        ? Icons.swap_horiz
        : (tx.type == TxType.income ? Icons.south_west : Icons.north_east);
    final tint = isTransfer ? viz.inkSecondary : (tx.type == TxType.income ? viz.good : scheme.primary);
    return Semantics(
      label: '$title, ${formatMoney(effect, showSign: true)}, $subtitle${tx.pending ? ', waiting to sync' : ''}',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: tint, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(
                        child: Text(title,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
                    if (tx.receiptPath != null)
                      Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(Icons.attach_file, size: 14, color: viz.inkMuted)),
                    if (tx.pending)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(Icons.cloud_upload_outlined, size: 14, color: viz.inkMuted),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: viz.inkSecondary)),
                ]),
              ),
              const SizedBox(width: 12),
              Text(formatMoney(effect, showSign: true), style: moneyStyle(context, color: amountColor)),
            ]),
          ),
        ),
      ),
    );
  }
}

Future<int?> pickDateTime(BuildContext context, int initialMs, String tz) async {
  final init = instantToZonedLocal(initialMs, tz);
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime(init.year, init.month, init.day),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: init.hour, minute: init.minute),
  );
  if (time == null) return null;
  return zonedLocalToInstant(date.year, date.month, date.day, time.hour, time.minute, tz);
}
