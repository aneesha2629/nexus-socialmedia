import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/adapters.dart';

const _uid = Uuid();

class DB {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final DB _i = DB._();
  factory DB() => _i;
  DB._();

  late Box<PostModel>    posts;
  late Box<CommentModel> comments;
  late Box<NotifModel>   notifs;
  late Box<UserModel>    friends;
  late Box<UserModel>    requests;
  late Box<dynamic>      session;
  late Box<dynamic>      settings;
  late Box<StoryModel>   stories;

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    registerAdapters();
    posts    = await Hive.openBox<PostModel>(B.posts);
    comments = await Hive.openBox<CommentModel>(B.comments);
    notifs   = await Hive.openBox<NotifModel>(B.notifs);
    friends  = await Hive.openBox<UserModel>(B.friends);
    requests = await Hive.openBox<UserModel>(B.requests);
    session  = await Hive.openBox<dynamic>(B.session);
    settings = await Hive.openBox<dynamic>(B.settings);
    stories  = await Hive.openBox<StoryModel>(B.stories);
    await _seed();
  }

  // ── Seed ───────────────────────────────────────────────────────────────────
  Future<void> _seed() async {
    if (posts.isNotEmpty) return;
    final now = DateTime.now();

    // Friends
    final f = [
      UserModel(id:'f1', name:'Sara Ahmed',   username:'sara_a',  bio:'Flutter Dev 💙',   initials:'SA', isOnline:true,  friendsCount:120, mutualCount:8),
      UserModel(id:'f2', name:'Mike K.',       username:'mike_k',  bio:'Photographer 📷',  initials:'MK', isOnline:true,  friendsCount:98,  mutualCount:5),
      UserModel(id:'f3', name:'Luna R.',       username:'luna_r',  bio:'Designer 🌙',       initials:'LR', isOnline:false, friendsCount:210, mutualCount:12),
      UserModel(id:'f4', name:'James D.',      username:'james_d', bio:'Music 🎸',          initials:'JD', isOnline:true,  friendsCount:75,  mutualCount:3),
      UserModel(id:'f5', name:'Nadia W.',      username:'nadia_w', bio:'Bookworm 📚',        initials:'NW', isOnline:false, friendsCount:160, mutualCount:6),
    ];
    for (final u in f) friends.put(u.id, u);

    // Friend requests
    final r = [
      UserModel(id:'r1', name:'Amir Levi',    username:'amir_l',  bio:'Software Engineer', initials:'AL', mutualCount:4),
      UserModel(id:'r2', name:'Zara Hussain', username:'zara_h',  bio:'UX Designer',        initials:'ZH', mutualCount:7),
    ];
    for (final u in r) requests.put(u.id, u);

    // Posts
    final pp = [
      PostModel(id:'p1', authorId:'f1', authorName:'Sara Ahmed', authorInitials:'SA', content:'Just shipped a new feature — real-time collaborative editing! The team absolutely crushed it this sprint. 🚀 #WebDev #TeamWork', createdAt:now.subtract(const Duration(minutes:5)),  privacyIdx:0, likesCount:24, commentsCount:2, sharesCount:3),
      PostModel(id:'p2', authorId:'f2', authorName:'Mike K.',    authorInitials:'MK', content:'Golden hour from the rooftop last evening. Sometimes you just have to stop and appreciate the little things. 🌅', imageEmoji:'🌅', createdAt:now.subtract(const Duration(minutes:34)), privacyIdx:1, likesCount:87, commentsCount:1, sharesCount:7),
      PostModel(id:'p3', authorId:'f3', authorName:'Luna R.',    authorInitials:'LR', content:'Hot take: the best productivity hack is being genuinely interested in what you work on. No app beats curiosity. #Productivity', createdAt:now.subtract(const Duration(hours:2)),   privacyIdx:0, likesCount:142, commentsCount:2, sharesCount:19, isLiked:true),
      PostModel(id:'p4', authorId:'f4', authorName:'James D.',   authorInitials:'JD', content:'New song draft done! Cannot wait to share it with you all. 🎸 #Music #NewRelease', createdAt:now.subtract(const Duration(hours:5)),   privacyIdx:0, likesCount:55, commentsCount:8, sharesCount:4),
    ];
    for (final p in pp) posts.put(p.id, p);

    // Comments
    final cc = [
      CommentModel(id:'c1', postId:'p1', authorId:'f2', authorName:'Mike K.',    text:"That's incredible! Congrats to the whole team!",     createdAt:now.subtract(const Duration(minutes:3))),
      CommentModel(id:'c2', postId:'p1', authorId:'f3', authorName:'Luna R.',    text:'Real-time collab is no joke. Props!',                  createdAt:now.subtract(const Duration(minutes:2))),
      CommentModel(id:'c3', postId:'p2', authorId:'f1', authorName:'Sara Ahmed', text:'Gorgeous! What camera are you using?',                 createdAt:now.subtract(const Duration(minutes:20))),
      CommentModel(id:'c4', postId:'p3', authorId:'f5', authorName:'Nadia W.',   text:'100% agree. Interest is the best motivator.',          createdAt:now.subtract(const Duration(hours:1))),
      CommentModel(id:'c5', postId:'p3', authorId:'f4', authorName:'James D.',   text:'Curiosity + discipline is the real combo.',             createdAt:now.subtract(const Duration(hours:1, minutes:30))),
    ];
    for (final c in cc) comments.put(c.id, c);

    // Notifications
    final nn = [
      NotifModel(id:'n1', boldPart:'Sara Ahmed', body:' liked your photo',          icon:'❤️', isRead:false, createdAt:now.subtract(const Duration(minutes:2))),
      NotifModel(id:'n2', boldPart:'Mike K.',    body:' commented on your post',    icon:'💬', isRead:false, createdAt:now.subtract(const Duration(minutes:15))),
      NotifModel(id:'n3', boldPart:'Amir Levi',  body:' sent you a friend request', icon:'👥', isRead:false, createdAt:now.subtract(const Duration(hours:1))),
      NotifModel(id:'n4', boldPart:'Luna R.',    body:' tagged you in a post',      icon:'🏷️', isRead:true,  createdAt:now.subtract(const Duration(hours:3))),
      NotifModel(id:'n5', boldPart:'James D.',   body:' started following you',     icon:'✨', isRead:true,  createdAt:now.subtract(const Duration(days:1))),
    ];
    for (final n in nn) notifs.put(n.id, n);
  }

  // ── Session / Auth ─────────────────────────────────────────────────────────
  bool   get isLoggedIn => session.get('in', defaultValue: false) as bool;
  String get myName     => session.get('name',     defaultValue: 'Yusuf Al-Amin') as String;
  String get myUsername => session.get('username', defaultValue: 'yusuf') as String;
  String get myBio      => session.get('bio',      defaultValue: 'Flutter developer ☕') as String;
  String get myInitials => session.get('initials', defaultValue: 'YA') as String;
  String? get myProfilePic => session.get('profilePic') as String?;
  int? get myAge => session.get('age') as int?;

  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (username.trim().isEmpty || password.isEmpty) return false;
    await session.putAll({'in': true, 'username': username.trim()});
    
    // Save to SharedPreferences for persistent login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username.trim());
    
    return true;
  }

  Future<bool> register(String name, String username, String password, int age) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (name.trim().isEmpty || username.trim().isEmpty || password.length < 6) return false;
    final initials = name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    await session.putAll({
      'in': true, 
      'name': name.trim(), 
      'username': username.trim(), 
      'initials': initials,
      'age': age
    });
    
    // Save to SharedPreferences for persistent login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('name', name.trim());
    await prefs.setString('username', username.trim());
    await prefs.setString('initials', initials);
    await prefs.setInt('age', age);
    
    return true;
  }

  Future<void> logout() async {
    await session.put('in', false);
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> updateProfile(String name, String username, String bio) async {
    final initials = name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    await session.putAll({'name': name.trim(), 'username': username.trim(), 'bio': bio.trim(), 'initials': initials});
    
    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name.trim());
    await prefs.setString('username', username.trim());
    await prefs.setString('bio', bio.trim());
    await prefs.setString('initials', initials);
  }

  Future<void> updateProfilePicture(String imagePath) async {
    await session.put('profilePic', imagePath);
    
    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePic', imagePath);
  }

  Future<void> restoreSession(String name, String username, String bio, String initials, String? profilePic, int? age) async {
    await session.putAll({
      'in': true,
      'name': name,
      'username': username,
      'bio': bio,
      'initials': initials,
      if (profilePic != null) 'profilePic': profilePic,
      if (age != null) 'age': age,
    });
  }

  // ── Posts ──────────────────────────────────────────────────────────────────
  List<PostModel> getPosts() => posts.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> createPost({required String content, String? imageEmoji, int privacyIdx = 0, String? imagePath}) async {
    final p = PostModel(
      id: _uid.v4(), 
      authorId: 'me', 
      authorName: myName, 
      authorInitials: myInitials, 
      content: content, 
      imageEmoji: imageEmoji, 
      createdAt: DateTime.now(), 
      privacyIdx: privacyIdx,
      authorProfilePic: myProfilePic,
      postImage: imagePath,
    );
    await posts.put(p.id, p);
  }

  Future<void> toggleLike(String postId) async {
    final p = posts.get(postId); if (p == null) return;
    p.isLiked    = !p.isLiked;
    p.likesCount += p.isLiked ? 1 : -1;
    await p.save();
  }

  Future<void> toggleSave(String postId) async {
    final p = posts.get(postId); if (p == null) return;
    p.isSaved = !p.isSaved; await p.save();
  }

  Future<void> sharePost(String postId) async {
    final p = posts.get(postId); if (p == null) return;
    p.sharesCount++; await p.save();
  }

  Future<void> deletePost(String postId) async {
    await posts.delete(postId);
    final ids = comments.values.where((c) => c.postId == postId).map((c) => c.id).toList();
    for (final id in ids) await comments.delete(id);
  }

  // ── Comments ───────────────────────────────────────────────────────────────
  List<CommentModel> getComments(String postId) =>
      comments.values.where((c) => c.postId == postId).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> addComment(String postId, String text) async {
    final c = CommentModel(id: _uid.v4(), postId: postId, authorId: 'me', authorName: myName, text: text, createdAt: DateTime.now());
    await comments.put(c.id, c);
    final p = posts.get(postId); if (p != null) { p.commentsCount++; await p.save(); }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await comments.delete(commentId);
    final p = posts.get(postId); if (p != null) { p.commentsCount = (p.commentsCount - 1).clamp(0, 99999); await p.save(); }
  }

  // ── Friends ────────────────────────────────────────────────────────────────
  List<UserModel> getFriends()  => friends.values.toList();
  List<UserModel> getRequests() => requests.values.toList();

  Future<void> acceptRequest(String id) async {
    final u = requests.get(id); if (u == null) return;
    await friends.put(id, u);
    await requests.delete(id);
    await addNotif(boldPart: u.name, body: ' accepted your friend request', icon: '🎉');
  }

  Future<void> declineRequest(String id) async => requests.delete(id);
  Future<void> removeFriend(String id)    async => friends.delete(id);

  // ── Notifications ──────────────────────────────────────────────────────────
  List<NotifModel> getNotifs() => notifs.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  int get unreadCount => notifs.values.where((n) => !n.isRead).length;

  Future<void> addNotif({required String boldPart, required String body, required String icon}) async {
    final n = NotifModel(id: _uid.v4(), boldPart: boldPart, body: body, icon: icon, createdAt: DateTime.now());
    await notifs.put(n.id, n);
  }

  Future<void> markRead(String id)    async { final n = notifs.get(id); if(n==null)return; n.isRead=true; await n.save(); }
  Future<void> markAllRead()          async { for(final n in notifs.values){ n.isRead=true; await n.save(); } }
  Future<void> deleteNotif(String id) async => notifs.delete(id);

  // ── Settings ───────────────────────────────────────────────────────────────
  bool getSetting(String key, {bool def = true}) => settings.get(key, defaultValue: def) as bool;
  Future<void> setSetting(String key, bool v)    async => settings.put(key, v);

  // ── Stories ────────────────────────────────────────────────────────────────
  List<StoryModel> getStories() {
    final now = DateTime.now();
    // Remove expired stories
    final expired = stories.values.where((s) => s.isExpired).map((s) => s.id).toList();
    for (final id in expired) {
      stories.delete(id);
    }
    // Return active stories sorted by creation time
    return stories.values.where((s) => !s.isExpired).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createStory({String? imagePath, String? text}) async {
    if ((imagePath == null || imagePath.isEmpty) && (text == null || text.isEmpty)) return;
    
    final now = DateTime.now();
    final story = StoryModel(
      id: _uid.v4(),
      authorId: 'me',
      authorName: myName,
      authorInitials: myInitials,
      authorProfilePic: myProfilePic,
      imagePath: imagePath,
      text: text,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
    await stories.put(story.id, story);
  }

  Future<void> deleteStory(String storyId) async {
    await stories.delete(storyId);
  }

  Future<void> viewStory(String storyId, String viewerId) async {
    final story = stories.get(storyId);
    if (story != null && !story.viewedBy.contains(viewerId)) {
      story.viewedBy.add(viewerId);
      await story.save();
    }
  }
}
