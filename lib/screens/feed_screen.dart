import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/story_bar.dart';
import 'create_post_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final auth  = ref.watch(authProvider);

    return RefreshIndicator(
      onRefresh: () async { ref.read(postsProvider.notifier).refresh(); await Future.delayed(const Duration(milliseconds: 400)); },
      child: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        const StoryBar(),
        const SizedBox(height: 8),

        // Create post tile
        Card(margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Row(children: [
              CircleAvatar(radius: 20, backgroundColor: T.primary,
                child: Text(auth.initials, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () => _createPost(context, ref),
                child: Container(height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("What's on your mind, ${auth.name.split(' ').first}?",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14))))),
            ]),
            const Divider(height: 18),
            Row(children: [
              _createBtn(context, ref, '📷', 'Photo'),
              _createBtn(context, ref, '🎥', 'Video'),
              _createBtn(context, ref, '😊', 'Feeling'),
            ]),
          ]))),
        const SizedBox(height: 8),

        // Posts
        if (posts.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 60),
            child: Column(children: [
              Text('📭', style: TextStyle(fontSize: 52)),
              SizedBox(height: 12),
              Text('No posts yet', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Be the first to share something!', style: TextStyle(color: Colors.grey)),
            ]))
        else
          ...posts.map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: PostCard(post: p))),
      ]),
    );
  }

  Widget _createBtn(BuildContext ctx, WidgetRef ref, String e, String label) => Expanded(
    child: TextButton.icon(onPressed: () => _createPost(ctx, ref),
      icon: Text(e, style: const TextStyle(fontSize: 16)),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600)));

  void _createPost(BuildContext ctx, WidgetRef ref) {
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
  }
}
