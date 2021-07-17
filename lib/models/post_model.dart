import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram/config/paths.dart';
import 'package:meta/meta.dart';
import 'models.dart';

class Post extends Equatable {
  final String id; //id of document;
  final User author;
  final String caption;
  final String imageUrl;
  final int likes;
  final DateTime date;
  //we are having user here instead of document reference because when we grab
  //document reference we will convert it into user

  const Post({
    this.id, //firebase automatically generates the id
    @required this.author,
    @required this.caption,
    @required this.imageUrl,
    @required this.likes,
    @required this.date,
  });

  @override
  List<Object> get props => [id, author, caption, imageUrl, likes, date];

  Post copyWith({
    String id,
    User author,
    String caption,
    String imageUrl,
    int likes,
    DateTime date,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'author':
          FirebaseFirestore.instance.collection(Paths.users).doc(author.id),
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'date': Timestamp.fromDate(date),
    };
  }

  static Future<Post> fromDocument(DocumentSnapshot doc) async {
    if (doc == null) return null;
    final data = doc.data() as Map<String, dynamic>;
    final authorRef = data['author'] as DocumentReference;
    if (authorRef != null) {
      final authorDoc = await authorRef.get();
      if (authorDoc.exists) {
        return Post(
          id: doc.id,
          author: User.fromDocument(authorDoc),
          caption: data['caption'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          likes: (data['likes'] ?? 0).toInt(),
          date: (data['date'] as Timestamp)?.toDate(),
        );
      }
    }
    return null;
  }
  //we do not use a factory constructor here as we have to convert document reference to user
}
