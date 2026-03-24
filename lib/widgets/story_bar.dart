import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/profile_picture.dart';
import '../screens/create_story_screen.dart';
import '../screens/story_view_screen.dart';

class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);
    final auth = ref.watch(authProvider);
    
    // Get my stories and others' stories
    final myStories = stories.where((s) => s.authorId == 'me').toList();
    final otherStories = stories.where((s) => s.authorId != 'me').toList();
    
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: SizedBox(
        height: 98,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          children: [
            // Add story button
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: ProfilePicture(
                            imagePath: auth.profilePicture,
                            initials: auth.initials,
                            size: 52,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: T.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(
                      width: 56,
                      child: Text(
                        'Add Story',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // My stories
            ...myStories.map((story) => _StoryItem(
              story: story,
              isMyStory: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryViewScreen(
                    stories: [story],
                    initialIndex: 0,
                  ),
                ),
              ),
            )),
            
            // Others' stories
            ...otherStories.map((story) => _StoryItem(
              story: story,
              isMyStory: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryViewScreen(
                    stories: [story],
                    initialIndex: 0,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final dynamic story;
  final bool isMyStory;
  final VoidCallback onTap;

  const _StoryItem({
    required this.story,
    required this.isMyStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasViewed = story.viewedBy.contains('me');
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasViewed || isMyStory
                  ? null
                  : const LinearGradient(
                      colors: [T.primary, T.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                border: hasViewed || isMyStory
                  ? Border.all(color: Colors.grey.shade300, width: 2)
                  : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ProfilePicture(
                  imagePath: story.authorProfilePic,
                  initials: story.authorInitials,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: Text(
                isMyStory ? 'Your Story' : story.authorName.split(' ').first,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
