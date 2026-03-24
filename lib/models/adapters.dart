import 'package:hive/hive.dart';
import 'models.dart';

class UserAdapter extends TypeAdapter<UserModel> {
  @override final int typeId = 0;
  @override
  UserModel read(BinaryReader r) => UserModel(
    id: r.readString(), name: r.readString(), username: r.readString(),
    bio: r.readString(), initials: r.readString(),
    isOnline: r.readBool(), friendsCount: r.readInt(), mutualCount: r.readInt(),
    profilePicture: r.readBool() ? r.readString() : null,
    age: r.readBool() ? r.readInt() : null,
  );
  @override
  void write(BinaryWriter w, UserModel o) {
    w..writeString(o.id)..writeString(o.name)..writeString(o.username)
     ..writeString(o.bio)..writeString(o.initials)
     ..writeBool(o.isOnline)..writeInt(o.friendsCount)..writeInt(o.mutualCount)
     ..writeBool(o.profilePicture != null);
    if (o.profilePicture != null) w.writeString(o.profilePicture!);
    w..writeBool(o.age != null);
    if (o.age != null) w.writeInt(o.age!);
  }
}

class PostAdapter extends TypeAdapter<PostModel> {
  @override final int typeId = 1;
  @override
  PostModel read(BinaryReader r) => PostModel(
    id: r.readString(), authorId: r.readString(), authorName: r.readString(),
    authorInitials: r.readString(), content: r.readString(),
    imageEmoji: r.readBool() ? r.readString() : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
    privacyIdx: r.readInt(), likesCount: r.readInt(), commentsCount: r.readInt(),
    sharesCount: r.readInt(), isLiked: r.readBool(), isSaved: r.readBool(),
    authorProfilePic: r.readBool() ? r.readString() : null,
    postImage: r.readBool() ? r.readString() : null,
  );
  @override
  void write(BinaryWriter w, PostModel o) {
    w..writeString(o.id)..writeString(o.authorId)..writeString(o.authorName)
     ..writeString(o.authorInitials)..writeString(o.content)
     ..writeBool(o.imageEmoji != null);
    if (o.imageEmoji != null) w.writeString(o.imageEmoji!);
    w..writeInt(o.createdAt.millisecondsSinceEpoch)
     ..writeInt(o.privacyIdx)..writeInt(o.likesCount)..writeInt(o.commentsCount)
     ..writeInt(o.sharesCount)..writeBool(o.isLiked)..writeBool(o.isSaved)
     ..writeBool(o.authorProfilePic != null);
    if (o.authorProfilePic != null) w.writeString(o.authorProfilePic!);
    w..writeBool(o.postImage != null);
    if (o.postImage != null) w.writeString(o.postImage!);
  }
}

class CommentAdapter extends TypeAdapter<CommentModel> {
  @override final int typeId = 2;
  @override
  CommentModel read(BinaryReader r) => CommentModel(
    id: r.readString(), postId: r.readString(), authorId: r.readString(),
    authorName: r.readString(), text: r.readString(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
  );
  @override
  void write(BinaryWriter w, CommentModel o) {
    w..writeString(o.id)..writeString(o.postId)..writeString(o.authorId)
     ..writeString(o.authorName)..writeString(o.text)
     ..writeInt(o.createdAt.millisecondsSinceEpoch);
  }
}

class NotifAdapter extends TypeAdapter<NotifModel> {
  @override final int typeId = 3;
  @override
  NotifModel read(BinaryReader r) => NotifModel(
    id: r.readString(), boldPart: r.readString(), body: r.readString(),
    icon: r.readString(), isRead: r.readBool(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
  );
  @override
  void write(BinaryWriter w, NotifModel o) {
    w..writeString(o.id)..writeString(o.boldPart)..writeString(o.body)
     ..writeString(o.icon)..writeBool(o.isRead)
     ..writeInt(o.createdAt.millisecondsSinceEpoch);
  }
}

class StoryAdapter extends TypeAdapter<StoryModel> {
  @override final int typeId = 4;
  @override
  StoryModel read(BinaryReader r) => StoryModel(
    id: r.readString(),
    authorId: r.readString(),
    authorName: r.readString(),
    authorInitials: r.readString(),
    authorProfilePic: r.readBool() ? r.readString() : null,
    imagePath: r.readBool() ? r.readString() : null,
    text: r.readBool() ? r.readString() : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
    expiresAt: DateTime.fromMillisecondsSinceEpoch(r.readInt()),
    viewedBy: r.readStringList(),
  );
  @override
  void write(BinaryWriter w, StoryModel o) {
    w..writeString(o.id)..writeString(o.authorId)..writeString(o.authorName)
     ..writeString(o.authorInitials)
     ..writeBool(o.authorProfilePic != null);
    if (o.authorProfilePic != null) w.writeString(o.authorProfilePic!);
    w..writeBool(o.imagePath != null);
    if (o.imagePath != null) w.writeString(o.imagePath!);
    w..writeBool(o.text != null);
    if (o.text != null) w.writeString(o.text!);
    w..writeInt(o.createdAt.millisecondsSinceEpoch)
     ..writeInt(o.expiresAt.millisecondsSinceEpoch)
     ..writeStringList(o.viewedBy);
  }
}

void registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PostAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CommentAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NotifAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(StoryAdapter());
}
