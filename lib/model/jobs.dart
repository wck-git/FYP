import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/timeZoneConverter.dart';

class Jobs {
  static const String collectionName = "jobs";
  String jobId;
  final String recruiterId;
  final String jobName;
  final DateTime jobStartTime;
  final DateTime jobEndTime;
  final double jobPay;
  final String businessName;
  final String firstLineAddress;
  final String states;
  final DateTime jobPostedDateTime;
  final bool applicantIsFound;

  Jobs({
    this.jobId = "",
    required this.recruiterId,
    required this.jobName,
    required this.jobStartTime,
    required this.jobEndTime,
    required this.jobPostedDateTime,
    required this.businessName,
    required this.firstLineAddress,
    required this.states,
    required this.jobPay,
    required this.applicantIsFound,
  });

  factory Jobs.fromJson(Map<String, dynamic> json) {
    return Jobs(
      jobId: json['jobId'],
      recruiterId: json['recruiterId'],
      jobName: json['jobName'],
      jobStartTime: TimeZoneConverterHelper.convertUtcToMYTime(
          (json['jobStartTime'] as Timestamp).toDate()),
      jobEndTime: TimeZoneConverterHelper.convertUtcToMYTime(
          (json['jobEndTime'] as Timestamp).toDate()),
      jobPay: json['jobPay'],
      businessName: json['businessName'],
      firstLineAddress: json['firstLineAddress'],
      states: json['states'],
      jobPostedDateTime: (json['jobPostedDateTime'] as Timestamp).toDate(),
      applicantIsFound: json['applicantIsFound'],
    );
  }

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'recruiterId': recruiterId,
        'jobName': jobName,
        'jobStartTime': jobStartTime,
        'jobEndTime': jobEndTime,
        'jobPay': jobPay,
        'businessName': businessName,
        'firstLineAddress': firstLineAddress,
        'states': states,
        'jobPostedDateTime': jobPostedDateTime,
        'applicantIsFound': applicantIsFound,
      };
}
