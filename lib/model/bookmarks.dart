import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmarks {
  static const String collectionName = "bookmarks";
  String bookmarkId;
  final String userId;
  final String jobId;
  final DateTime bookmarkAddedDateTime;

  Bookmarks({
    this.bookmarkId = "",
    required this.userId,
    required this.jobId,
    required this.bookmarkAddedDateTime,
  });

  factory Bookmarks.fromJson(Map<String, dynamic> json) {
    return Bookmarks(
      bookmarkId: json['bookmarkId'],
      userId: json['userId'],
      jobId: json['jobId'],
      bookmarkAddedDateTime:
          (json['bookmarkAddedDateTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'bookmarkId': bookmarkId,
        'userId': userId,
        'jobId': jobId,
        'bookmarkAddedDateTime': bookmarkAddedDateTime,
      };
}
