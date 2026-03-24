import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});
  @override ConsumerState<FriendsScreen> createState() => _State();
}

class _State extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose()   { _tab.dispose(); super.dispose(); }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: T.primary));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendsProvider);
    return Column(children: [
      Container(color: Theme.of(context).appBarTheme.backgroundColor,
        child: TabBar(controller: _tab,
          labelColor: T.primary, unselectedLabelColor: Colors.grey, indicatorColor: T.primary,
          tabs: [const Tab(text: 'Friends'), Tab(text: 'Requests (${state.requests.length})'), const Tab(text: 'Suggest')])),
      Expanded(child: TabBarView(controller: _tab, children: [

        // ── Friends ──────────────────────────────────────────────────────────
        state.friends.isEmpty
          ? _empty('👥', 'No friends yet')
          : ListView.builder(padding: const EdgeInsets.all(12), itemCount: state.friends.length,
              itemBuilder: (_, i) {
                final f = state.friends[i];
                return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                  leading: Stack(children: [
                    CircleAvatar(radius: 22, backgroundColor: T.avatarColor(f.id),
                      child: Text(f.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    if (f.isOnline) Positioned(bottom: 0, right: 0, child: Container(width: 11, height: 11,
                      decoration: BoxDecoration(color: T.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                  ]),
                  title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(f.bio, style: const TextStyle(fontSize: 12)),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'msg', child: Text('💬 Message')),
                      const PopupMenuItem(value: 'rm',  child: Text('Remove Friend', style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (v) async {
                      if (v == 'rm') { await ref.read(friendsProvider.notifier).remove(f.id); _snack('${f.name} removed'); }
                      if (v == 'msg') _snack('Messaging coming soon!');
                    }),
                ));
              }),

        // ── Requests ─────────────────────────────────────────────────────────
        state.requests.isEmpty
          ? _empty('👍', 'No pending requests')
          : ListView.builder(padding: const EdgeInsets.all(12), itemCount: state.requests.length,
              itemBuilder: (_, i) {
                final u = state.requests[i];
                return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    CircleAvatar(radius: 24, backgroundColor: T.avatarColor(u.id),
                      child: Text(u.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${u.mutualCount} mutual friends', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ])),
                    Column(children: [
                      SizedBox(height: 34, child: ElevatedButton(onPressed: () async { await ref.read(friendsProvider.notifier).accept(u.id); _snack('${u.name} is now your friend! 🎉'); },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                        child: const Text('Accept', style: TextStyle(fontSize: 12)))),
                      const SizedBox(height: 6),
                      SizedBox(height: 34, child: OutlinedButton(onPressed: () => ref.read(friendsProvider.notifier).decline(u.id),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                        child: const Text('Decline', style: TextStyle(fontSize: 12)))),
                    ]),
                  ])));
              }),

        // ── Suggestions ───────────────────────────────────────────────────────
        _SuggestTab(),
      ])),
    ]);
  }

  Widget _empty(String e, String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(e, style: const TextStyle(fontSize: 44)), const SizedBox(height: 10),
    Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 15)),
  ]));
}

class _SuggestTab extends StatefulWidget {
  @override State<_SuggestTab> createState() => _SuggestState();
}

class _SuggestState extends State<_SuggestTab> {
  final Set<String> _sent = {};
  static const _people = [
    {'id':'s1','name':'Kai Nguyen',  'initials':'KN','mutual':3,'bio':'Engineer 🛠️'},
    {'id':'s2','name':'Priya Rao',   'initials':'PR','mutual':5,'bio':'Designer 🎨'},
    {'id':'s3','name':'Tom Osei',    'initials':'TO','mutual':2,'bio':'Writer ✍️'},
    {'id':'s4','name':'Dana Lee',    'initials':'DL','mutual':7,'bio':'Artist 🎭'},
    {'id':'s5','name':'Omar Hassan', 'initials':'OH','mutual':4,'bio':'Developer 💻'},
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _people.where((p) => !_sent.contains(p['id'])).toList();
    if (visible.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('✅', style: TextStyle(fontSize: 44)), const SizedBox(height: 10),
      const Text('All caught up!', style: TextStyle(color: Colors.grey)),
    ]));
    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: visible.length,
      itemBuilder: (_, i) {
        final p = visible[i];
        return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: CircleAvatar(radius: 22, backgroundColor: T.avatarColor(p['id'] as String),
            child: Text(p['initials'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
          title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('${p['mutual']} mutual friends · ${p['bio']}', style: const TextStyle(fontSize: 12)),
          trailing: ElevatedButton(
            onPressed: () { setState(() => _sent.add(p['id'] as String)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to ${p['name']}'))); },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14), minimumSize: Size.zero),
            child: const Text('+ Add', style: TextStyle(fontSize: 12))),
        ));
      });
  }
}
