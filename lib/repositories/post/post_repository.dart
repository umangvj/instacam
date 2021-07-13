import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram/config/paths.dart';
import 'package:flutter_instagram/enums/enums.dart';
import 'package:flutter_instagram/models/models.dart';
import 'package:flutter_instagram/repositories/repositories.dart';
import 'package:meta/meta.dart';

class PostRepository extends BasePostRepository {
  FirebaseFirestore _firebaseFirestore;

  PostRepository({FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({@required Post post}) async {
    await _firebaseFirestore.collection(Paths.posts).add(post.toDocument());
  }

  @override
  Future<void> createComment(
      {@required Post post, @required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postComments)
        .add(comment.toDocument());

    final notification = Notif(
      type: NotifType.comment,
      fromUser: comment.author,
      post: post,
      date: DateTime.now(),
    );
    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post.author.id)
        .collection(Paths.userNotifications)
        .add(notification.toDocument());
  }

  @override
  void createLike({@required Post post, @required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post.id)
        .update({'likes': FieldValue.increment(1)});
    //we use FieldValue because it directly updates in the database instead of fetching the
    //value(post.likes) and doing +1. So if multiple users like the post there will be no
    //problem of increment of likes.

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userId)
        .set({});

    final notification = Notif(
      type: NotifType.like,
      fromUser: User.empty.copyWith(id: userId),
      post: post,
      date: DateTime.now(),
    );
    _firebaseFirestore
        .collection(Paths.notifications)
        .doc(post.author.id)
        .collection(Paths.userNotifications)
        .add(notification.toDocument());
  }

  @override
  Stream<List<Future<Post>>> getUserPosts({@required String userId}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    return _firebaseFirestore
        .collection(Paths.posts) //goes to post collection
        .where('author',
            isEqualTo: authorRef) //looks for matching author with authorRef
        .orderBy('date',
            descending: true) //to get most recent posts at beginning of list
        .snapshots() //to create stream which returns query snapshots
        .map((snap) => snap.docs.map((doc) => Post.fromDocument(doc)).toList());
    //we map over these snapshots take the document from the query snapshot and then map over
    //the list of query document snapshots and turn each one into a post model and
    //toList converts to list of future posts

    // DO NOT FORGET TO ADD COMPOSITE INDEX (in firestore indexes section) AS WE ARE QUERYING
    // FOR TWO FIELDS i.e AUTHOR AND DATE.
  }

  @override
  Stream<List<Future<Comment>>> getUserComments({@required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postComments)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  @override
  Future<List<Post>> getUserFeed({
    @required String userId,
    String lastPostId,
  }) async {
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .limit(5)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .doc(lastPostId)
          .get();
      if (!lastPostDoc.exists) {
        return [];
      }
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(5)
          .get();
    }

    final posts = Future.wait(
      postsSnap.docs.map((doc) => Post.fromDocument(doc)).toList(),
    );
    return posts;
  }

  //we will fetch this method after fetching new batch of posts.
  @override
  Future<Set<String>> getLikedPostIds({
    @required String userId,
    @required List<Post> posts,
  }) async {
    final postIds = <String>{};
    for (final post in posts) {
      final likeDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post.id)
          .collection(Paths.postLikes)
          .doc(userId)
          .get();
      if (likeDoc.exists) {
        postIds.add(post.id);
      }
    }
    return postIds;
  }

  @override
  void deleteLike({@required String postId, @required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(postId)
        .collection(Paths.postLikes)
        .doc(userId)
        .delete();
  }
}
