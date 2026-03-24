import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'feed_screen.dart';
import 'friends_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override ConsumerState<HomeScreen> createState() => _State();
}

class _State extends ConsumerState<HomeScreen> {
  int _idx = 0;
  String? _live;
  Timer? _liveTimer, _livePeriodic;

  static const _events = [
    ['❤️', 'Sara Ahmed', ' liked your post'],
    ['💬', 'Mike K.',    ' commented on your photo'],
    ['👥', 'Luna R.',    ' shared your post'],
    ['✨', 'James D.',   ' started following you'],
    ['🔥', 'Nadia W.',   ' reacted to your story'],
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _fire);
    _livePeriodic = Timer.periodic(const Duration(seconds: 8), (_) => _fire());
  }

  void _fire() {
    if (!mounted) return;
    final e = _events[Random().nextInt(_events.length)];
    ref.read(notifsProvider.notifier).add(e[1], e[2], e[0]);
    setState(() => _live = '${e[0]}  ${e[1]}${e[2]}');
    _liveTimer?.cancel();
    _liveTimer = Timer(const Duration(seconds: 4), () { if (mounted) setState(() => _live = null); });
  }

  @override
  void dispose() { _liveTimer?.cancel(); _livePeriodic?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final unread   = ref.watch(unreadProvider);
    final auth     = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Text('◈', style: TextStyle(fontSize: 22, color: T.primary)),
          SizedBox(width: 6),
          Text('Nexus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: T.primary, letterSpacing: -0.5)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () =>
            showSearch(context: context, delegate: _Search())),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _idx = 3),
              child: CircleAvatar(radius: 18, backgroundColor: T.primary,
                child: Text(auth.initials, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))))),
        ],
        bottom: _live != null ? PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(width: double.infinity, color: const Color(0xFFF0FDF4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: T.green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('Live · ', style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
              Expanded(child: Text(_live!, style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)), overflow: TextOverflow.ellipsis)),
            ])),
        ) : null,
      ),
      body: IndexedStack(index: _idx, children: const [FeedScreen(), FriendsScreen(), NotificationsScreen(), ProfileScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) { setState(() => _idx = i); if (i == 2) ref.read(notifsProvider.notifier).markAll(); },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined),        selectedIcon: Icon(Icons.home_rounded),         label: 'Feed'),
          const NavigationDestination(icon: Icon(Icons.people_outline),       selectedIcon: Icon(Icons.people_rounded),       label: 'Friends'),
          NavigationDestination(
            icon: Badge(isLabelVisible: unread > 0, label: Text(unread > 9 ? '9+' : '$unread'),
              child: const Icon(Icons.notifications_outlined)),
            selectedIcon: const Icon(Icons.notifications_rounded), label: 'Notifications'),
          const NavigationDestination(icon: Icon(Icons.person_outline),       selectedIcon: Icon(Icons.person_rounded),       label: 'Profile'),
        ],
      ),
    );
  }
}

class _Search extends SearchDelegate<String> {
  final _all = ['Sara Ahmed', 'Mike K.', 'Luna R.', 'James D.', 'Nadia W.', '#WebDev', '#Flutter', '#AIArt', '#OpenSource', '#Productivity'];
  @override List<Widget> buildActions(BuildContext ctx) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override Widget buildLeading(BuildContext ctx) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(ctx, ''));
  @override Widget buildResults(BuildContext ctx) => _list(ctx);
  @override Widget buildSuggestions(BuildContext ctx) => _list(ctx);
  Widget _list(BuildContext ctx) {
    final r = _all.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
    if (r.isEmpty) return const Center(child: Text('No results'));
    return ListView.builder(itemCount: r.length,
      itemBuilder: (_, i) => ListTile(
        leading: CircleAvatar(backgroundColor: T.primary.withOpacity(0.1),
          child: Text(r[i][0], style: const TextStyle(color: T.primary, fontWeight: FontWeight.w700))),
        title: Text(r[i]),
        onTap: () { query = r[i]; showResults(ctx); }));
  }
}
