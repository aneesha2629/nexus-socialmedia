import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notifsProvider);
    final unread = notifs.where((n) => !n.isRead).length;

    return Column(children: [
      if (unread > 0)
        Container(color: T.primary.withOpacity(0.07),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Text('$unread unread', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: T.primary)),
            const Spacer(),
            TextButton(onPressed: () => ref.read(notifsProvider.notifier).markAll(),
              child: const Text('Mark all read', style: TextStyle(color: T.primary, fontSize: 13))),
          ])),

      Expanded(child: notifs.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🔔', style: TextStyle(fontSize: 52)), SizedBox(height: 12),
            Text("You're all caught up!", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            SizedBox(height: 4), Text('No new notifications', style: TextStyle(color: Colors.grey)),
          ]))
        : ListView.separated(
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = notifs[i];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red.shade50, alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade400)),
                onDismissed: (_) => ref.read(notifsProvider.notifier).remove(n.id),
                child: InkWell(
                  onTap: () => ref.read(notifsProvider.notifier).markRead(n.id),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 300),
                    color: n.isRead ? null : T.primary.withOpacity(0.04),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(children: [
                      Container(width: 46, height: 46,
                        decoration: BoxDecoration(color: T.primary.withOpacity(0.1), shape: BoxShape.circle),
                        child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 21)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        RichText(text: TextSpan(
                          style: TextStyle(fontSize: 13.5, color: Theme.of(context).colorScheme.onBackground),
                          children: [
                            TextSpan(text: n.boldPart, style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(text: n.body),
                          ])),
                        const SizedBox(height: 3),
                        Text(n.timeAgo, style: TextStyle(fontSize: 12, color: n.isRead ? Colors.grey.shade400 : T.primary, fontWeight: n.isRead ? FontWeight.normal : FontWeight.w500)),
                      ])),
                      if (!n.isRead)
                        Container(width: 9, height: 9, decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle)),
                    ])),
                ),
              );
            },
          )),
    ]);
  }
}
