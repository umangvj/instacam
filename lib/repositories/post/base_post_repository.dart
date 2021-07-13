import 'package:flutter_instagram/models/models.dart';

abstract class BasePostRepository {
  Future<void> createPost({Post post});

  Future<void> createComment({Post post, Comment comment});

  void createLike({Post post, String userId});

  Stream<List<Future<Post>>> getUserPosts({String userId});

  //used to fetch users post (not feed!)
  Stream<List<Future<Comment>>> getUserComments({String postId});

  //used to fetch comments of a post when on comments screen
  Future<List<Post>> getUserFeed({String userId, String lastPostId});

  //used to fetch feed posts of a user as per his following. lastPostId is used for pagination.
  Future<Set<String>> getLikedPostIds({String userId, List<Post> posts});
  void deleteLike({String postId, String userId});
}
