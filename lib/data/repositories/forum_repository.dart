import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/forum_post_model.dart';

class ForumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'forum_posts';

  Future<String> createPost(ForumPostModel post) async {
    try {
      final docRef = await _firestore.collection(collectionName).add(post.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create forum post: $e');
    }
  }

  Future<void> updatePost(String postId, ForumPostModel post) async {
    try {
      await _firestore.collection(collectionName).doc(postId).update({
        ...post.toMap(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update forum post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(collectionName).doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete forum post: $e');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(collectionName).doc(postId);
      
      // Check if already liked
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final data = postDoc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        
        if (likedBy.contains(userId)) {
          // Unlike
          await postRef.update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Like
          await postRef.update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to like/unlike post: $e');
    }
  }

  Stream<List<ForumPostModel>> streamAllPosts() {
    return _firestore
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ForumPostModel.fromFirestore(doc)).toList());
  }

  Future<List<ForumPostModel>> getAllPosts() async {
    try {
      final query = await _firestore
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      
      return query.docs.map((doc) => ForumPostModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get forum posts: $e');
    }
  }
}
