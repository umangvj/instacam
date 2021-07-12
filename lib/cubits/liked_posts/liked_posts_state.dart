part of 'liked_posts_cubit.dart';

class LikedPostsState extends Equatable {
  final Set<String> likedPostIds;
  final Set<String> recentlyLikedPostIds;
  // posts user has just liked in the current session of the app. To know when to increment
  // the post like by one or not when liking in user feed or profile feed.

  const LikedPostsState({
    @required this.likedPostIds,
    @required this.recentlyLikedPostIds,
  });

  factory LikedPostsState.initial() {
    return LikedPostsState(likedPostIds: {}, recentlyLikedPostIds: {});
  }

  @override
  List<Object> get props => [likedPostIds, recentlyLikedPostIds];

  LikedPostsState copyWith({
    Set<String> likedPostIds,
    Set<String> recentlyLikedPostIds,
  }) {
    return LikedPostsState(
      likedPostIds: likedPostIds ?? this.likedPostIds,
      recentlyLikedPostIds: recentlyLikedPostIds ?? this.recentlyLikedPostIds,
    );
  }
}
