import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_services.dart';
import '../models/post_model.dart';
import 'patient_common_widgets.dart';

/// Posts Page - صفحة المنشورات
///
/// Displays posts from Firebase web_posts collection
/// Features:
/// - View all posts
/// - Like posts
/// - Add comments
class PatientPosts extends StatefulWidget {
  const PatientPosts({super.key});

  @override
  State<PatientPosts> createState() => _PatientPostsState();
}

class _PatientPostsState extends State<PatientPosts> {
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  final Map<String, bool> _isLiking = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _isAddingComment = {};
  final Map<String, bool> _hasLiked = {}; // Track which posts user has liked

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    // Dispose all comment controllers
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() => _isLoading = true);
      final posts = await _firebaseServices.getAllPosts();
      final currentUserId = _firebaseServices.currentUserId;

      // Debug: Print image URLs
      for (var post in posts) {
        print(
          '[Posts] Post ${post.id}: image="${post.image}", image is null: ${post.image == null}, image isEmpty: ${post.image?.isEmpty ?? true}',
        );
      }

      if (mounted) {
        // Check which posts user has liked
        final likedByMap = <String, bool>{};
        if (currentUserId != null) {
          for (var post in posts) {
            // Check if post has likedBy field in Firebase
            // We'll need to fetch this separately or include it in PostModel
            likedByMap[post.id] = false; // Default to false, will be updated
          }
        }

        setState(() {
          _posts = posts;
          _hasLiked.clear();
          _hasLiked.addAll(likedByMap);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[Posts] Error loading posts: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المنشورات: $e')));
      }
    }
  }

  Future<void> _likePost(String postId) async {
    // Prevent multiple likes from same user
    if (_isLiking[postId] == true || _hasLiked[postId] == true) {
      print('[Posts] User already liked this post or is currently liking');
      return;
    }

    setState(() => _isLiking[postId] = true);

    try {
      final newLikes = await _firebaseServices.likePost(postId);
      if (mounted) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == postId);
          if (index != -1) {
            _posts[index] = PostModel(
              id: _posts[index].id,
              title: _posts[index].title,
              content: _posts[index].content,
              authorId: _posts[index].authorId,
              authorName: _posts[index].authorName,
              category: _posts[index].category,
              image: _posts[index].image,
              likes: newLikes,
              comments: _posts[index].comments,
              createdAt: _posts[index].createdAt,
            );
          }
          _hasLiked[postId] = true; // Mark as liked
          _isLiking[postId] = false;
        });
      }
    } catch (e) {
      print('[Posts] Error liking post: $e');
      if (mounted) {
        setState(() => _isLiking[postId] = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في الإعجاب: $e')));
      }
    }
  }

  Future<void> _addComment(String postId) async {
    final controller = _commentControllers[postId];
    if (controller == null || controller.text.trim().isEmpty) {
      return;
    }

    if (_isAddingComment[postId] == true) return;

    setState(() => _isAddingComment[postId] = true);

    try {
      await _firebaseServices.addCommentToPost(
        postId: postId,
        commentText: controller.text.trim(),
      );

      // Reload posts to get updated comments
      await _loadPosts();

      if (mounted) {
        controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة التعليق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('[Posts] Error adding comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في إضافة التعليق: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingComment[postId] = false);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير متوفر';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: buildPatientDrawer(context, theme),
      appBar: AppBar(
        title: const Text('المنشورات'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منشورات',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return _buildPostCard(context, theme, post);
                },
              ),
            ),
      bottomNavigationBar: buildPatientBottomNavBar(
        context,
        theme,
        currentIndex: 1, // المنشورات
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, ThemeData theme, PostModel post) {
    // Initialize comment controller if not exists
    if (!_commentControllers.containsKey(post.id)) {
      _commentControllers[post.id] = TextEditingController();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? 'مستخدم',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.category ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Image (if exists) - Show image properly
          if (post.image != null && post.image!.isNotEmpty) ...[
            Builder(
              builder: (context) {
                final imageUrl = post.image!.trim();
                print(
                  '[Posts] Rendering image for post ${post.id}: "$imageUrl"',
                );

                // Check if it's a direct HTTP/HTTPS URL
                final isHttpUrl =
                    imageUrl.startsWith('http://') ||
                    imageUrl.startsWith('https://');

                // Check if it's a Firebase Storage path (gs:// or storage path)
                final isStoragePath =
                    imageUrl.startsWith('gs://') ||
                    (!isHttpUrl &&
                        !imageUrl.contains('://') &&
                        imageUrl.isNotEmpty);

                if (isHttpUrl) {
                  // Direct HTTP/HTTPS URL - use Image.network directly
                  return _buildNetworkImage(imageUrl, imageUrl);
                } else if (isStoragePath) {
                  // Firebase Storage path - get download URL first
                  return FutureBuilder<String?>(
                    future: _getStorageDownloadUrl(imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        print(
                          '[Posts] Error getting download URL: ${snapshot.error}',
                        );
                        return _buildImageError(imageUrl);
                      }

                      final downloadUrl = snapshot.data!;
                      print('[Posts] Got download URL: $downloadUrl');
                      return _buildNetworkImage(downloadUrl, imageUrl);
                    },
                  );
                } else {
                  // Invalid format
                  print('[Posts] Image is not a valid URL or path: $imageUrl');
                  return _buildImageError(imageUrl);
                }
              },
            ),
          ],

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title != null && post.title!.isNotEmpty)
                  Text(
                    post.title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (post.title != null && post.title!.isNotEmpty)
                  const SizedBox(height: 8),
                if (post.content != null && post.content!.isNotEmpty)
                  Text(post.content!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          // Actions (Like, Comment)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Like button (only one like per user)
                InkWell(
                  onTap: _hasLiked[post.id] == true
                      ? null // Disable if already liked
                      : () => _likePost(post.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _isLiking[post.id] == true
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                _hasLiked[post.id] == true
                                    ? Icons
                                          .favorite // Filled heart if liked
                                    : Icons
                                          .favorite_border, // Empty heart if not liked
                                size: 20,
                                color: _hasLiked[post.id] == true
                                    ? Colors
                                          .red // Red if liked
                                    : theme
                                          .colorScheme
                                          .primary, // Primary color if not liked
                              ),
                        const SizedBox(width: 4),
                        Text(
                          post.likes.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _hasLiked[post.id] == true
                                ? Colors.red
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Comment icon
                Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  post.comments.length.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (post.comments.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التعليقات (${post.comments.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...post.comments.map((comment) {
                    final commentText = comment['text'] as String? ?? '';
                    final authorName =
                        comment['authorName'] as String? ?? 'مستخدم';
                    final createdAt = comment['createdAt'];
                    DateTime? commentDate;
                    if (createdAt is Timestamp) {
                      commentDate = createdAt.toDate();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  commentText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                if (commentDate != null)
                                  Text(
                                    _formatDate(commentDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // Add comment section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentControllers[post.id],
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقاً...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                _isAddingComment[post.id] == true
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _addComment(post.id),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build network image widget
  Widget _buildNetworkImage(String imageUrl, String originalUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('[Posts] Image loaded successfully: $imageUrl');
              return child;
            }
            return Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('[Posts] Error loading image: $error, URL: $imageUrl');
            return _buildImageError(originalUrl);
          },
        ),
      ),
    );
  }

  /// Get download URL from Firebase Storage
  Future<String?> _getStorageDownloadUrl(String path) async {
    try {
      // Remove gs:// prefix if present
      String storagePath = path;
      if (path.startsWith('gs://')) {
        // Extract path from gs://bucket-name/path/to/file
        final parts = path.split('/');
        if (parts.length > 3) {
          storagePath = parts.sublist(3).join('/');
        } else {
          print('[Posts] Invalid gs:// URL format: $path');
          return null;
        }
      }

      print('[Posts] Getting download URL for storage path: $storagePath');
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      print('[Posts] Download URL obtained: $url');
      return url;
    } catch (e) {
      print('[Posts] Error getting download URL from Firebase Storage: $e');
      // Try as direct path if gs:// conversion failed
      try {
        final ref = FirebaseStorage.instance.ref().child(path);
        final url = await ref.getDownloadURL();
        print('[Posts] Download URL obtained (direct path): $url');
        return url;
      } catch (e2) {
        print('[Posts] Error with direct path: $e2');
        return null;
      }
    }
  }

  /// Build error widget for image
  Widget _buildImageError(String url) {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'فشل تحميل الصورة',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (url.length > 50) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  url.substring(0, 50) + '...',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
