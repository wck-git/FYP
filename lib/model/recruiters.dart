class Recruiters {
  static const String collectionName = "recruiters";
  String recruiterId;
  final String recruiterEmail;
  final String mobileNum;
  final String name;
  final String gender;
  final String businessName;
  final String firstLineAddress;
  final String states;
  final String image;

  Recruiters({
    this.recruiterId = "",
    required this.recruiterEmail,
    required this.mobileNum,
    required this.name,
    required this.gender,
    required this.businessName,
    required this.firstLineAddress,
    required this.states,
    required this.image,
  });

  factory Recruiters.fromJson(Map<String, dynamic> json) {
    return Recruiters(
      recruiterId: json['recruiterId'],
      recruiterEmail: json['recruiterEmail'],
      mobileNum: json['mobileNum'],
      name: json['name'],
      gender: json['gender'],
      businessName: json['businessName'],
      firstLineAddress: json['firstLineAddress'],
      states: json['states'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'recruiterId': recruiterId,
        'recruiterEmail': recruiterEmail,
        'mobileNum': mobileNum,
        'name': name,
        'gender': gender,
        'businessName': businessName,
        'firstLineAddress': firstLineAddress,
        'states': states,
        'image': image,
      };
}
