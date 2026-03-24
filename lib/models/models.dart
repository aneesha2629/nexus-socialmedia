import 'package:hive/hive.dart';

// ─── Box names ────────────────────────────────────────────────────────────────
class B {
  static const posts     = 'posts';
  static const comments  = 'comments';
  static const notifs    = 'notifs';
  static const friends   = 'friends';
  static const requests  = 'requests';
  static const session   = 'session';
  static const settings  = 'settings';
  static const stories   = 'stories';
}

// ─── Privacy ──────────────────────────────────────────────────────────────────
enum Privacy { public, friends, onlyMe }

extension PrivacyX on Privacy {
  String get label => ['🌐 Public', '👥 Friends', '🔒 Only Me'][index];
}

// ─── UserModel ────────────────────────────────────────────────────────────────
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String name;
  @HiveField(2)  String username;
  @HiveField(3)  String bio;
  @HiveField(4)  String initials;
  @HiveField(5)  bool   isOnline;
  @HiveField(6)  int    friendsCount;
  @HiveField(7)  int    mutualCount;
  @HiveField(8)  String? profilePicture;
  @HiveField(9)  int?   age;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.bio          = '',
    this.initials     = '',
    this.isOnline     = false,
    this.friendsCount = 0,
    this.mutualCount  = 0,
    this.profilePicture,
    this.age,
  });
}

// ─── PostModel ────────────────────────────────────────────────────────────────
@HiveType(typeId: 1)
class PostModel extends HiveObject {
  @HiveField(0)  String   id;
  @HiveField(1)  String   authorId;
  @HiveField(2)  String   authorName;
  @HiveField(3)  String   authorInitials;
  @HiveField(4)  String   content;
  @HiveField(5)  String?  imageEmoji;
  @HiveField(6)  DateTime createdAt;
  @HiveField(7)  int      privacyIdx;
  @HiveField(8)  int      likesCount;
  @HiveField(9)  int      commentsCount;
  @HiveField(10) int      sharesCount;
  @HiveField(11) bool     isLiked;
  @HiveField(12) bool     isSaved;
  @HiveField(13) String?  authorProfilePic;
  @HiveField(14) String?  postImage;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    this.imageEmoji,
    required this.createdAt,
    this.privacyIdx   = 0,
    this.likesCount   = 0,
    this.commentsCount= 0,
    this.sharesCount  = 0,
    this.isLiked      = false,
    this.isSaved      = false,
    this.authorProfilePic,
    this.postImage,
  });

  Privacy get privacy => Privacy.values[privacyIdx];

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inSeconds < 60)  return 'Just now';
    if (d.inMinutes < 60)  return '${d.inMinutes}m';
    if (d.inHours   < 24)  return '${d.inHours}h';
    return '${d.inDays}d';
  }
}

// ─── CommentModel ─────────────────────────────────────────────────────────────
@HiveType(typeId: 2)
class CommentModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   postId;
  @HiveField(2) String   authorId;
  @HiveField(3) String   authorName;
  @HiveField(4) String   text;
  @HiveField(5) DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }
}

// ─── StoryModel ───────────────────────────────────────────────────────────────
@HiveType(typeId: 4)
class StoryModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   authorId;
  @HiveField(2) String   authorName;
  @HiveField(3) String   authorInitials;
  @HiveField(4) String?  authorProfilePic;
  @HiveField(5) String?  imagePath;
  @HiveField(6) String?  text;
  @HiveField(7) DateTime createdAt;
  @HiveField(8) DateTime expiresAt;
  @HiveField(9) List<String> viewedBy;

  StoryModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    this.authorProfilePic,
    this.imagePath,
    this.text,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }
}
@HiveType(typeId: 3)
class NotifModel extends HiveObject {
  @HiveField(0) String   id;
  @HiveField(1) String   boldPart;
  @HiveField(2) String   body;
  @HiveField(3) String   icon;
  @HiveField(4) bool     isRead;
  @HiveField(5) DateTime createdAt;

  NotifModel({
    required this.id,
    required this.boldPart,
    required this.body,
    required this.icon,
    this.isRead = false,
    required this.createdAt,
  });

  String get timeAgo {
    final d = DateTime.now().difference(createdAt);
    if (d.inSeconds < 60)  return 'Just now';
    if (d.inMinutes < 60)  return '${d.inMinutes}m ago';
    if (d.inHours   < 24)  return '${d.inHours}h ago';
    if (d.inDays    < 7)   return '${d.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
