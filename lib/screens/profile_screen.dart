import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_picture.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override ConsumerState<ProfileScreen> createState() => _State();
}

class _State extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _picker = ImagePicker();
  
  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose()   { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth     = ref.watch(authProvider);
    final posts    = ref.watch(postsProvider).where((p) => p.authorId == 'me').toList();
    final friends  = ref.watch(friendsProvider).friends;
    final saved    = ref.watch(postsProvider).where((p) => p.isSaved).length;
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(child: Column(children: [
      // Cover + Avatar
      Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Container(height: 140, width: double.infinity,
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [T.primary, T.accent], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        Positioned(bottom: -40, child: Stack(children: [
          GestureDetector(
            onTap: _changeProfilePicture,
            child: Container(
              width: 86, 
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ProfilePicture(
                imagePath: auth.profilePicture,
                initials: auth.initials,
                size: 80,
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: T.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          if (settings.showOnline) Positioned(bottom: 2, left: 2,
            child: Container(width: 20, height: 20, decoration: BoxDecoration(color: T.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
        ])),
      ]),
      const SizedBox(height: 52),

      Text(auth.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text('@${auth.username}', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      if (auth.bio.isNotEmpty) ...[
        const SizedBox(height: 7),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(auth.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.45))),
      ],
      const SizedBox(height: 16),

      // Stats
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _stat('Posts', '${posts.length}'),
        _divider(),
        _stat('Friends', '${friends.length}'),
        _divider(),
        _stat('Saved', '$saved'),
      ]),
      const SizedBox(height: 16),

      // Buttons
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: () => _editProfile(context, auth.name, auth.username, auth.bio),
          icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit Profile'))),
        const SizedBox(width: 10),
        OutlinedButton(onPressed: () => _privacy(context), child: const Icon(Icons.lock_outline, size: 18)),
        const SizedBox(width: 10),
        OutlinedButton(onPressed: () => _confirmLogout(context),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade400),
          child: const Icon(Icons.logout, size: 18)),
      ])),
      const SizedBox(height: 16),

      TabBar(controller: _tab,
        labelColor: T.primary, unselectedLabelColor: Colors.grey, indicatorColor: T.primary,
        tabs: const [Tab(text: 'My Posts'), Tab(text: 'Photos'), Tab(text: 'About')]),

      SizedBox(height: 400, child: TabBarView(controller: _tab, children: [
        // My Posts
        posts.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📝', style: TextStyle(fontSize: 44)), const SizedBox(height: 10),
              const Text('No posts yet', style: TextStyle(color: Colors.grey)),
            ])))
          : ListView.builder(padding: const EdgeInsets.all(12), itemCount: posts.length,
              itemBuilder: (_, i) {
                final p = posts[i];
                return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.content, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.favorite_border, size: 15, color: Colors.grey.shade500), const SizedBox(width: 4),
                      Text('${p.likesCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)), const SizedBox(width: 12),
                      Icon(Icons.chat_bubble_outline, size: 15, color: Colors.grey.shade500), const SizedBox(width: 4),
                      Text('${p.commentsCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async { await ref.read(postsProvider.notifier).delete(p.id); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted'))); },
                        child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300)),
                    ]),
                  ])));
              }),

        // Photos
        GridView.builder(padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: 9,
          itemBuilder: (_, i) => Container(decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(['🌅','🚀','🌸','🌙','🎸','📚','☕','🎨','🌿'][i], style: const TextStyle(fontSize: 36))))),

        // About
        ListView(padding: const EdgeInsets.all(16), children: [
          // Personal Info Section
          const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _editableInfo(Icons.person_outline, 'Name', auth.name, () => _editField('name', auth.name)),
          _editableInfo(Icons.alternate_email, 'Username', '@${auth.username}', () => _editField('username', auth.username)),
          if (auth.age != null)
            _info(Icons.cake_outlined, 'Age: ${auth.age} years'),
          _editableInfo(Icons.info_outline, 'Bio', auth.bio.isEmpty ? 'Add a bio...' : auth.bio, () => _editField('bio', auth.bio)),
          
          const SizedBox(height: 18),
          const Text('Contact & Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _info(Icons.work_outline,      'Flutter Developer'),
          _info(Icons.location_on_outlined,'Karachi, Pakistan'),
          _info(Icons.link,              'nexus.app/@${auth.username}'),
          _info(Icons.calendar_today_outlined, 'Joined March 2022'),
          const SizedBox(height: 18),
          const Text('Privacy Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          _badge('Profile',      settings.publicProfile   ? 'Public'   : 'Private',  settings.publicProfile   ? T.green  : Colors.orange),
          _badge('Online',       settings.showOnline      ? 'Visible'  : 'Hidden',   settings.showOnline      ? T.green  : Colors.grey),
          _badge('Friend Reqs',  settings.allowReqs       ? 'Allowed'  : 'Blocked',  settings.allowReqs       ? T.green  : Colors.red),
          _badge('Tag Approval', settings.tagApproval     ? 'On'       : 'Off',      settings.tagApproval     ? T.green  : Colors.grey),
          const SizedBox(height: 18),
          const Text('App', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          ListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode', style: TextStyle(fontSize: 14)),
            leading: const Icon(Icons.dark_mode_outlined),
            trailing: Switch(value: settings.darkMode, activeColor: T.primary,
              onChanged: (v) => ref.read(settingsProvider.notifier).toggle('dark', v))),
        ]),
      ])),
    ]));
  }

  Widget _stat(String l, String v) => Padding(padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Column(children: [Text(v, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), Text(l, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))]));

  Widget _divider() => Container(width: 1, height: 32, color: Colors.grey.shade300);

  Widget _info(IconData icon, String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 10), Text(t, style: const TextStyle(fontSize: 13))]));

  Widget _editableInfo(IconData icon, String label, String value, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: value.contains('Add') ? Colors.grey.shade400 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit, size: 16, color: Colors.grey.shade400),
        ],
      ),
    ),
  );
  Widget _badge(String l, String v, Color c) => Padding(padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [Text(l, style: const TextStyle(fontSize: 13)), const Spacer(),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(v, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w700)))]));

  void _editProfile(BuildContext ctx, String name, String username, String bio) {
    final nc = TextEditingController(text: name);
    final uc = TextEditingController(text: username);
    final bc = TextEditingController(text: bio);
    showModalBottomSheet(context: ctx, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(controller: nc, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 10),
          TextField(controller: uc, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 10),
          TextField(controller: bc, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () async {
            await ref.read(authProvider.notifier).updateProfile(nc.text, uc.text, bc.text);
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('✅ Profile updated!'))); }
          }, child: const Text('Save Changes')),
          const SizedBox(height: 20),
        ])));
  }

  void _privacy(BuildContext ctx) {
    showModalBottomSheet(context: ctx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Consumer(builder: (_, ref, __) {
        final s = ref.watch(settingsProvider);
        final n = ref.read(settingsProvider.notifier);
        return Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Privacy Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _pTile('🌐 Public Profile',       'Anyone can see your profile',         s.publicProfile,   (v) => n.toggle('pub',    v)),
          _pTile('🟢 Show Online Status',   "Friends see when you're online",       s.showOnline,      (v) => n.toggle('online', v)),
          _pTile('👥 Allow Friend Requests','Anyone can send you requests',         s.allowReqs,       (v) => n.toggle('reqs',   v)),
          _pTile('🏷️ Review Tags',          'Approve before they appear on profile',s.tagApproval,    (v) => n.toggle('tags',   v)),
          const SizedBox(height: 8),
        ]));
      }));
  }

  Widget _pTile(String t, String s, bool v, Function(bool) on) => ListTile(contentPadding: EdgeInsets.zero,
    title: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    subtitle: Text(s, style: const TextStyle(fontSize: 12)),
    trailing: Switch(value: v, onChanged: on, activeColor: T.primary));

  void _confirmLogout(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Text('Sign Out'), content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async { await ref.read(authProvider.notifier).logout(); if (ctx.mounted) Navigator.pop(ctx); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sign Out')),
      ]));
  }

  Future<void> _changeProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        await ref.read(authProvider.notifier).updateProfilePicture(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Profile picture updated!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _editField(String field, String currentValue) {
    final controller = TextEditingController(text: field == 'username' ? currentValue : currentValue);
    final isMultiline = field == 'bio';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit ${field == 'bio' ? 'Bio' : field == 'name' ? 'Name' : 'Username'}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: isMultiline ? 4 : 1,
              maxLength: field == 'bio' ? 150 : field == 'name' ? 50 : 30,
              textCapitalization: field == 'name' ? TextCapitalization.words : TextCapitalization.none,
              decoration: InputDecoration(
                labelText: field == 'bio' ? 'Tell people about yourself' : 
                          field == 'name' ? 'Your full name' : 'Username',
                hintText: field == 'bio' ? 'I love coding and coffee ☕' :
                         field == 'name' ? 'John Doe' : 'john_doe',
                prefixText: field == 'username' ? '@' : null,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isEmpty && field != 'bio') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${field == 'name' ? 'Name' : 'Username'} cannot be empty')),
                  );
                  return;
                }
                
                if (field == 'name' && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(newValue)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name can only contain letters and spaces')),
                  );
                  return;
                }
                
                if (field == 'username' && newValue.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username must be at least 3 characters')),
                  );
                  return;
                }
                
                final auth = ref.read(authProvider);
                final updatedName = field == 'name' ? newValue : auth.name;
                final updatedUsername = field == 'username' ? newValue : auth.username;
                final updatedBio = field == 'bio' ? newValue : auth.bio;
                
                await ref.read(authProvider.notifier).updateProfile(
                  updatedName,
                  updatedUsername,
                  updatedBio,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ ${field == 'bio' ? 'Bio' : field == 'name' ? 'Name' : 'Username'} updated!')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
