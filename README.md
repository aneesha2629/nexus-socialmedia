# ◈ Nexus Social

A full-featured social networking app built with **Flutter + Hive + Riverpod**.

---

## 🚀 Quick Start

```bash
# 1. Get dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. (Optional) Re-generate Hive adapters if you modify models
flutter pub run build_runner build --delete-conflicting-outputs
```

> **Login tip:** Any username + password works for demo. Password must be 6+ chars for signup.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry — Hive init + ProviderScope
│
├── models/
│   ├── models.dart              # All data models (UserModel, PostModel, CommentModel, NotifModel)
│   └── adapters.dart            # Manual Hive TypeAdapters — no codegen needed
│
├── services/
│   └── db.dart                  # Singleton DB — all Hive CRUD operations
│
├── providers/
│   └── providers.dart           # All Riverpod StateNotifierProviders
│
├── theme/
│   └── app_theme.dart           # Material 3 light + dark themes, color helpers
│
├── screens/
│   ├── login_screen.dart        # Sign In / Sign Up with validation
│   ├── home_screen.dart         # Bottom nav + live WebSocket event bar
│   ├── feed_screen.dart         # Stories, create post, scrollable feed
│   ├── friends_screen.dart      # Friends list, requests, suggestions
│   ├── notifications_screen.dart# Swipe-to-dismiss notifications
│   └── profile_screen.dart      # Profile, edit, privacy, dark mode toggle
│
└── widgets/
    ├── post_card.dart            # Full post: like animation, comments, share, save
    └── story_bar.dart            # Horizontal stories with seen/unseen rings
```

---

## ✅ Features

### Authentication
- Sign In / Sign Up with validation
- Session persisted in Hive — stays logged in after app restart
- Edit profile (name, username, bio)
- Sign out with confirmation dialog

### Feed
- Scrollable post feed — newest first
- Pull-to-refresh
- Create post with privacy selector (Public / Friends / Only Me)
- Stories bar with seen/unseen gradient rings

### Posts
- Like with bounce animation (persisted)
- Comment — add and delete your own comments
- Share — increments share count (persisted)
- Save / Unsave posts (persisted)
- Delete your own posts
- Post options via popup menu

### Friends
- Friends list with online status indicator
- Accept / Decline friend requests
- Remove friends
- People you may know (suggest)

### Notifications
- Real-time simulated WebSocket events every 8s
- Unread badge on bottom nav (auto-clears on tab open)
- Tap to mark as read
- Swipe left to dismiss
- "Mark all read" button

### Profile
- Cover photo with gradient
- Post count, friends count, saved count (all live)
- My Posts tab with delete
- Photos grid tab
- About tab with privacy badges
- Edit profile bottom sheet
- Privacy settings (public profile, online status, friend requests, tag approval)
- Dark mode toggle (persisted)

### Data Persistence (Hive)
- All posts, comments, likes, saves, shares persist across sessions
- Notifications persist
- Friend list and requests persist
- Settings (dark mode, privacy) persist
- User session persists

---

## 🏗️ Architecture

```
UI (ConsumerWidget)
    │  ref.watch(provider)
    ▼
StateNotifierProvider  ◄──── ref.read(provider.notifier).method()
    │
    ▼
DB (HiveService singleton)
    │
    ▼
Hive Boxes (local disk storage)
```

### Providers
| Provider | State | Actions |
|---|---|---|
| `authProvider` | `AuthState` (loggedIn, name, username, bio, initials) | login, register, logout, updateProfile |
| `postsProvider` | `List<PostModel>` | create, toggleLike, toggleSave, share, delete, refresh |
| `commentsProvider(postId)` | `List<CommentModel>` | add, remove |
| `friendsProvider` | `FriendsState` (friends, requests) | accept, decline, remove |
| `notifsProvider` | `List<NotifModel>` | markRead, markAll, remove, add |
| `unreadProvider` | `int` | derived from notifsProvider |
| `settingsProvider` | `SettingsState` | toggle(key, value) |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.4.9 | State management |
| `hive` | ^2.2.3 | Local NoSQL database |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration |
| `uuid` | ^4.3.3 | Unique ID generation |
| `intl` | ^0.19.0 | Date formatting |

---

## 🔌 Connecting to a Real Backend

Replace the `DB` class methods with API calls:

```dart
// In db.dart — replace local Hive ops with HTTP calls
Future<void> createPost({required String content, ...}) async {
  final res = await http.post(
    Uri.parse('https://api.yourapp.com/posts'),
    headers: {'Authorization': 'Bearer $token'},
    body: jsonEncode({'content': content}),
  );
  // Still save to Hive for offline support
  final post = PostModel.fromJson(jsonDecode(res.body));
  await posts.put(post.id, post);
}
```

For real WebSockets:
```dart
// In home_screen.dart — replace Timer with:
import 'package:web_socket_channel/web_socket_channel.dart';
final channel = WebSocketChannel.connect(Uri.parse('wss://api.yourapp.com/ws'));
channel.stream.listen((data) {
  final event = jsonDecode(data);
  ref.read(notifsProvider.notifier).add(event['bold'], event['body'], event['icon']);
});
```
