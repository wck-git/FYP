import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplications {
  static const String collectionName = "jobapplications";
  String jobApplicationId;
  final String userId;
  final String jobId;
  final DateTime jobAppliedDateTime;
  final String applicationStatus;

  JobApplications({
    this.jobApplicationId = "",
    required this.userId,
    required this.jobId,
    required this.jobAppliedDateTime,
    required this.applicationStatus,
  });

  factory JobApplications.fromJson(Map<String, dynamic> json) {
    return JobApplications(
      jobApplicationId: json['jobApplicationId'],
      userId: json['userId'],
      jobId: json['jobId'],
      jobAppliedDateTime: (json['jobAppliedDateTime'] as Timestamp).toDate(),
      applicationStatus: json['applicationStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'jobApplicationId': jobApplicationId,
        'userId': userId,
        'jobId': jobId,
        'jobAppliedDateTime': jobAppliedDateTime,
        'applicationStatus': applicationStatus,
      };
}
