import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_picture.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});
  @override ConsumerState<PostCard> createState() => _State();
}

class _State extends ConsumerState<PostCard> with SingleTickerProviderStateMixin {
  bool _showComments = false;
  final _ctrl = TextEditingController();
  late AnimationController _likeAC;
  late Animation<double>   _likeScale;

  @override
  void initState() {
    super.initState();
    _likeAC    = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _likeScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAC, curve: Curves.easeInOut));
  }

  @override void dispose() { _likeAC.dispose(); _ctrl.dispose(); super.dispose(); }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  Widget build(BuildContext context) {
    final post     = widget.post;
    final comments = ref.watch(commentsProvider(post.id));
    final auth     = ref.watch(authProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────────────────────
        Padding(padding: const EdgeInsets.fromLTRB(14, 14, 8, 8),
          child: Row(children: [
            ProfilePicture(
              imagePath: post.authorProfilePic,
              initials: post.authorInitials,
              size: 40,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Row(children: [
                Text(post.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Text(post.privacy.label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))),
              ]),
            ])),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
              onSelected: (v) async {
                if (v == 'del')   { await ref.read(postsProvider.notifier).delete(post.id);       _snack('Post deleted'); }
                if (v == 'save')  { await ref.read(postsProvider.notifier).toggleSave(post.id);  _snack(post.isSaved ? 'Removed from saved' : '✅ Saved!'); }
                if (v == 'share') { await ref.read(postsProvider.notifier).share(post.id);        _snack('Shared!'); }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'save',  child: Text(post.isSaved ? '🔖 Unsave' : '🔖 Save Post')),
                const PopupMenuItem(value: 'share', child: Text('↗ Share')),
                if (post.authorId == 'me')
                  const PopupMenuItem(value: 'del', child: Text('🗑 Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ])),

        // ── Content ───────────────────────────────────────────────────────────
        if (post.content.isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text(post.content, style: const TextStyle(fontSize: 14.5, height: 1.55))),

        // Post image
        if (post.postImage != null && post.postImage!.isNotEmpty)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            child: ClipRRect(
              child: Image.file(
                File(post.postImage!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),

        // Emoji image (fallback)
        if (post.imageEmoji != null && (post.postImage == null || post.postImage!.isEmpty))
          Container(height: 200, width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: Center(child: Text(post.imageEmoji!, style: const TextStyle(fontSize: 88)))),

        // ── Stats ─────────────────────────────────────────────────────────────
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            Row(children: [
              const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFE24B4A)),
              const SizedBox(width: 4),
              Text('${post.likesCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showComments = !_showComments),
              child: Text('${post.commentsCount} comments · ${post.sharesCount} shares',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          ])),

        Divider(height: 1),

        // ── Actions ───────────────────────────────────────────────────────────
        Row(children: [
          _Btn(
            icon: ScaleTransition(scale: _likeScale, child: Icon(
              post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18, color: post.isLiked ? const Color(0xFFE24B4A) : Colors.grey.shade600)),
            label: 'Like', active: post.isLiked,
            onTap: () { _likeAC.forward(from: 0); ref.read(postsProvider.notifier).toggleLike(post.id); }),
          _Btn(
            icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: _showComments ? T.primary : Colors.grey.shade600),
            label: 'Comment', active: _showComments,
            onTap: () => setState(() => _showComments = !_showComments)),
          _Btn(
            icon: Icon(Icons.share_outlined, size: 18, color: Colors.grey.shade600),
            label: 'Share', active: false,
            onTap: () => ref.read(postsProvider.notifier).share(post.id)),
          _Btn(
            icon: Icon(post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 18,
              color: post.isSaved ? T.primary : Colors.grey.shade600),
            label: 'Save', active: post.isSaved,
            onTap: () => ref.read(postsProvider.notifier).toggleSave(post.id)),
        ]),

        // ── Comments ──────────────────────────────────────────────────────────
        if (_showComments) ...[
          Divider(height: 1),
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            ...comments.map((c) => _CommentTile(c: c, postId: post.id)),
            const SizedBox(height: 8),
            Row(children: [
              CircleAvatar(radius: 15, backgroundColor: T.primary,
                child: Text(auth.initials, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _ctrl,
                onSubmitted: (v) async {
                  if (v.trim().isEmpty) return;
                  await ref.read(commentsProvider(post.id).notifier).add(v.trim());
                  ref.read(postsProvider.notifier).refresh();
                  _ctrl.clear();
                },
                decoration: InputDecoration(
                  hintText: 'Write a comment…', isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  suffixIcon: IconButton(icon: const Icon(Icons.send_rounded, size: 18, color: T.primary),
                    onPressed: () async {
                      if (_ctrl.text.trim().isEmpty) return;
                      await ref.read(commentsProvider(post.id).notifier).add(_ctrl.text.trim());
                      ref.read(postsProvider.notifier).refresh();
                      _ctrl.clear();
                    })),
              )),
            ]),
          ])),
        ],
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final Widget icon; final String label; final bool active; final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext ctx) => Expanded(child: InkWell(onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon, const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500,
          color: active ? T.primary : Colors.grey.shade600)),
      ]))));
}

class _CommentTile extends ConsumerWidget {
  final CommentModel c; final String postId;
  const _CommentTile({required this.c, required this.postId});
  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final me = ref.read(authProvider);
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 14, backgroundColor: T.primary.withOpacity(0.15),
          child: Text(c.authorName[0], style: const TextStyle(fontSize: 11, color: T.primary, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Expanded(child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surfaceVariant.withOpacity(0.35),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 3),
            Text(c.text, style: const TextStyle(fontSize: 13.5)),
            const SizedBox(height: 5),
            Row(children: [
              Text(c.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              if (c.authorId == 'me' || c.authorName == me.name) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await ref.read(commentsProvider(postId).notifier).remove(c.id);
                    ref.read(postsProvider.notifier).refresh();
                  },
                  child: Text('Delete', style: TextStyle(fontSize: 11, color: Colors.red.shade400))),
              ],
            ]),
          ]),
        )),
      ]));
  }
}
