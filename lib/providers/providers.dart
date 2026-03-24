import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/db.dart';

final db = DB();

// ── Auth ──────────────────────────────────────────────────────────────────────
class AuthState {
  final bool   loggedIn;
  final String name;
  final String username;
  final String bio;
  final String initials;
  final String? profilePicture;
  final int?   age;
  AuthState({required this.loggedIn, required this.name, required this.username, required this.bio, required this.initials, this.profilePicture, this.age});
  factory AuthState.fromDB() => AuthState(loggedIn: db.isLoggedIn, name: db.myName, username: db.myUsername, bio: db.myBio, initials: db.myInitials, profilePicture: db.myProfilePic, age: db.myAge);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.fromDB());

  Future<String?> login(String u, String p) async {
    if (u.trim().isEmpty || p.trim().isEmpty) {
      return 'Username aur password dalna zaroori hai';
    }
    final ok = await db.login(u, p);
    if (!ok) return 'Galat username ya password';
    state = AuthState.fromDB(); return null;
  }

  Future<String?> register(String name, String u, String p, int age) async {
    // Validation
    if (name.trim().isEmpty) return 'Naam dalna zaroori hai';
    if (name.trim().length < 2) return 'Naam kam se kam 2 letters ka hona chahiye';
    if (u.trim().isEmpty) return 'Username dalna zaroori hai';
    if (u.trim().length < 3) return 'Username kam se kam 3 characters ka hona chahiye';
    if (p.length < 6) return 'Password kam se kam 6 characters ka hona chahiye';
    if (age < 13) return 'Age kam se kam 13 saal honi chahiye';
    if (age > 100) return 'Sahi age daliye';
    
    // Check if name contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim())) {
      return 'Naam mein sirf letters aur spaces allowed hain';
    }
    
    final ok = await db.register(name, u, p, age);
    if (!ok) return 'Registration failed. Username already exists.';
    state = AuthState.fromDB(); return null;
  }

  Future<void> logout() async { await db.logout(); state = AuthState.fromDB(); }

  Future<void> updateProfile(String name, String u, String bio) async {
    await db.updateProfile(name, u, bio); state = AuthState.fromDB();
  }

  Future<void> updateProfilePicture(String imagePath) async {
    await db.updateProfilePicture(imagePath); state = AuthState.fromDB();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// ── Posts ─────────────────────────────────────────────────────────────────────
class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super(db.getPosts());

  void refresh() => state = db.getPosts();

  Future<void> create(String content, {String? emoji, int privacyIdx = 0, String? imagePath}) async {
    await db.createPost(content: content, imageEmoji: emoji, privacyIdx: privacyIdx, imagePath: imagePath);
    refresh();
  }

  Future<void> toggleLike(String id)  async { await db.toggleLike(id);  refresh(); }
  Future<void> toggleSave(String id)  async { await db.toggleSave(id);  refresh(); }
  Future<void> share(String id)       async { await db.sharePost(id);   refresh(); }
  Future<void> delete(String id)      async { await db.deletePost(id);  refresh(); }
}

final postsProvider = StateNotifierProvider<PostsNotifier, List<PostModel>>((ref) => PostsNotifier());

// ── Comments ──────────────────────────────────────────────────────────────────
class CommentsNotifier extends StateNotifier<List<CommentModel>> {
  final String postId;
  CommentsNotifier(this.postId) : super(db.getComments(postId));

  void refresh() => state = db.getComments(postId);

  Future<void> add(String text)              async { await db.addComment(postId, text); refresh(); }
  Future<void> remove(String commentId)      async { await db.deleteComment(commentId, postId); refresh(); }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier, List<CommentModel>, String>(
  (ref, postId) => CommentsNotifier(postId),
);

// ── Friends ───────────────────────────────────────────────────────────────────
class FriendsState {
  final List<UserModel> friends;
  final List<UserModel> requests;
  FriendsState({required this.friends, required this.requests});
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  FriendsNotifier() : super(FriendsState(friends: db.getFriends(), requests: db.getRequests()));

  void refresh() => state = FriendsState(friends: db.getFriends(), requests: db.getRequests());

  Future<void> accept(String id)  async { await db.acceptRequest(id); refresh(); }
  Future<void> decline(String id) async { await db.declineRequest(id); refresh(); }
  Future<void> remove(String id)  async { await db.removeFriend(id); refresh(); }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) => FriendsNotifier());

// ── Notifications ─────────────────────────────────────────────────────────────
class NotifsNotifier extends StateNotifier<List<NotifModel>> {
  NotifsNotifier() : super(db.getNotifs());

  void refresh() => state = db.getNotifs();

  Future<void> markRead(String id)  async { await db.markRead(id);    refresh(); }
  Future<void> markAll()            async { await db.markAllRead();   refresh(); }
  Future<void> remove(String id)    async { await db.deleteNotif(id); refresh(); }
  Future<void> add(String bold, String body, String icon) async {
    await db.addNotif(boldPart: bold, body: body, icon: icon); refresh();
  }
}

final notifsProvider   = StateNotifierProvider<NotifsNotifier, List<NotifModel>>((ref) => NotifsNotifier());
final unreadProvider   = Provider<int>((ref) => ref.watch(notifsProvider).where((n) => !n.isRead).length);

// ── Settings ──────────────────────────────────────────────────────────────────
class SettingsState {
  final bool publicProfile, showOnline, allowReqs, tagApproval, darkMode;
  SettingsState({required this.publicProfile, required this.showOnline, required this.allowReqs, required this.tagApproval, required this.darkMode});
  factory SettingsState.fromDB() => SettingsState(
    publicProfile: db.getSetting('pub'),
    showOnline:    db.getSetting('online'),
    allowReqs:     db.getSetting('reqs'),
    tagApproval:   db.getSetting('tags', def: false),
    darkMode:      db.getSetting('dark', def: false),
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.fromDB());
  Future<void> toggle(String key, bool v) async { await db.setSetting(key, v); state = SettingsState.fromDB(); }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());

// ── Stories ───────────────────────────────────────────────────────────────────
class StoriesNotifier extends StateNotifier<List<StoryModel>> {
  StoriesNotifier() : super(db.getStories());

  void refresh() => state = db.getStories();

  Future<void> create({String? imagePath, String? text}) async {
    await db.createStory(imagePath: imagePath, text: text);
    refresh();
  }

  Future<void> delete(String storyId) async {
    await db.deleteStory(storyId);
    refresh();
  }

  Future<void> view(String storyId, String viewerId) async {
    await db.viewStory(storyId, viewerId);
    refresh();
  }
}

final storiesProvider = StateNotifierProvider<StoriesNotifier, List<StoryModel>>((ref) => StoriesNotifier());
