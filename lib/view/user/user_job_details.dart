import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/helper/connectionChecker.dart';
import 'package:ckfyp02/model/bookmarks.dart';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/user/user_main.dart';
import 'package:ckfyp02/view/user/user_search_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/job_applications.dart';
import '../../model/jobs.dart';
import '../../model/recruiters.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserJobDetailsView extends StatefulWidget {
  Jobs job;
  String recruiterId;

  UserJobDetailsView({
    required this.job,
    required this.recruiterId,
  });

  @override
  State<UserJobDetailsView> createState() => _UserJobDetailsViewState();
}

class _UserJobDetailsViewState extends State<UserJobDetailsView> {
  int jobApplicantNum = 0;

  @override
  void initState() {
    super.initState();
    getApplicantNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(
            job: widget.job,
            recruiterId: widget.recruiterId,
            jobApplicantNum: jobApplicantNum,
          ),
          wideLayout: WideLayout(),
        ),
      ),
      bottomNavigationBar: UserBottomNavBarView(
        currentIndex: 0,
        onTap: (int index) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserMainView(index: index)));
        },
        isAtMainPage: false,
      ),
    );
  }

  Future<void> getApplicantNumber() async {
    try {
      final jobApplicationDoc = await FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .where('jobId', isEqualTo: widget.job.jobId)
          .get();

      setState(() {
        jobApplicantNum = jobApplicationDoc.docs.length;
      });
    } catch (e) {
      print(e);
    }
  }
}

class NarrowLayout extends StatefulWidget {
  Jobs job;
  String recruiterId;
  int jobApplicantNum;

  NarrowLayout({
    required this.job,
    required this.recruiterId,
    required this.jobApplicantNum,
  });

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User user = FirebaseAuth.instance.currentUser!;
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("h:mm a");
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // UI
    return loading
        ? const LoadingView()
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Recruiters.collectionName)
                .doc(widget.recruiterId)
                .snapshots(),
            builder: (context, recruitersSnapshot) {
              // error
              if (recruitersSnapshot.hasError) {
                return const Text('Error fetching details');
              }

              if (recruitersSnapshot.hasData &&
                  recruitersSnapshot.data!.exists) {
                // retrieve recruiter information
                final recruiterData = recruitersSnapshot.data!.data();
                Recruiters recruiterDetails =
                    Recruiters.fromJson(recruiterData!);

                return Column(
                  children: [
                    // image and name
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // image
                          Center(
                            child: CachedNetworkImage(
                              imageUrl: recruiterDetails.image,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              width: 125.0,
                              height: 125.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          // recruiter
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // name and gender
                              Text(
                                ('${recruiterDetails.name} (${getGender(recruiterDetails.gender)})'),
                                style: const TextStyle(
                                  fontFamily: Fonts.primaryFont,
                                  fontSize: Fonts.primaryFontSize,
                                ),
                              ),
                              const SizedBox(
                                height: 2.5,
                              ),
                              // mobile num
                              GestureDetector(
                                onTap: () async {
                                  final Uri call = Uri(
                                      scheme: "tel",
                                      path: recruiterDetails.mobileNum);

                                  if (await canLaunchUrl(call)) {
                                    launchUrl(call);
                                  }
                                },
                                child: Text(
                                  recruiterDetails.mobileNum,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                    color: Colours.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // job details
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 0.55)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // job name
                              Row(
                                children: [
                                  getJobImage(widget.job.jobName),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Text(
                                      widget.job.jobName,
                                      style: const TextStyle(
                                          fontFamily: Fonts.primaryFont,
                                          fontSize: Fonts.profileTitleFontSize,
                                          color: Colours.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              // divider
                              Container(
                                width: double.infinity,
                                height: 2.0,
                                color: Colours.primaryColor,
                              ),
                              const SizedBox(height: 10.0),
                              // business
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // icon
                                  const Icon(
                                    Icons.location_city,
                                    size: Images.userNarrowIconWidth,
                                    color: Colours.secondaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserSearchResultView(
                                                                searchText: widget
                                                                    .job
                                                                    .businessName,
                                                              )));
                                                },
                                                child: Text(
                                                  widget.job.businessName,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        Fonts.primaryFont,
                                                    fontSize:
                                                        Fonts.primaryFontSize,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationThickness: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2.5),
                                        Text(
                                          widget.job.firstLineAddress,
                                          style: const TextStyle(
                                            fontFamily: Fonts.primaryFont,
                                            fontSize: Fonts.primaryFontSize,
                                          ),
                                        ),
                                        const SizedBox(height: 2.5),
                                        Text(
                                          widget.job.states,
                                          style: const TextStyle(
                                              fontFamily: Fonts.primaryFont,
                                              fontSize: Fonts.primaryFontSize,
                                              color: Colours.primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              // date and time
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // icon
                                  const Icon(
                                    Icons.date_range,
                                    size: Images.userNarrowIconWidth,
                                    color: Colours.secondaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ("${timeFormatter.format(widget.job.jobStartTime)} - ${timeFormatter.format(widget.job.jobEndTime)}"),
                                          style: const TextStyle(
                                            fontFamily: Fonts.primaryFont,
                                            fontSize: Fonts.primaryFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              // joy pay
                              Row(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    size: Images.userNarrowIconWidth,
                                    color: Colours.secondaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Text(
                                      ('RM ${widget.job.jobPay.toStringAsFixed(2)} (${(widget.job.jobEndTime.difference(widget.job.jobStartTime).inMinutes / 60).toStringAsFixed(1)} hours)'),
                                      style: const TextStyle(
                                        fontFamily: Fonts.primaryFont,
                                        fontSize: Fonts.primaryFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              // applicant number
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: Images.userNarrowIconWidth,
                                    color: Colours.secondaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Text(
                                      'Applicant: ${widget.jobApplicantNum.toString()}',
                                      style: const TextStyle(
                                        fontFamily: Fonts.primaryFont,
                                        fontSize: Fonts.primaryFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              // description
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.description,
                                    size: Images.userNarrowIconWidth,
                                    color: Colours.secondaryColor,
                                  ),
                                  const SizedBox(width: 5.0),
                                  getJobDescription(widget.job.jobName),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              // additional notes
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Note: ".toUpperCase(),
                                      style: const TextStyle(
                                          color: Colours.feedbackIncorrectColor,
                                          fontFamily: Fonts.primaryFont,
                                          fontSize: Fonts.primaryFontSize,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    const TextSpan(
                                      text:
                                          "Once applied, you cannot cancel the application",
                                      style: TextStyle(
                                        fontFamily: Fonts.primaryFont,
                                        fontSize: Fonts.primaryFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // apply button
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(Jobs.collectionName)
                            .doc(widget.job.jobId)
                            .snapshots(),
                        builder: (context, jobsSnapshot) {
                          // error
                          if (jobsSnapshot.hasError) {
                            return const Text('Error fetching details');
                          }

                          // waiting
                          if (jobsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (jobsSnapshot.hasData &&
                              jobsSnapshot.data!.exists) {
                            final jobDoc = jobsSnapshot.data!;
                            final jobData = jobDoc.data()!;
                            Jobs job = Jobs.fromJson(jobData);

                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection(JobApplications.collectionName)
                                    .where('userId', isEqualTo: user.uid)
                                    .where('jobId', isEqualTo: job.jobId)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, jobApplicationsSnapshot) {
                                  // error
                                  if (jobApplicationsSnapshot.hasError) {
                                    return const Text('Error fetching details');
                                  }

                                  if (jobApplicationsSnapshot.hasData &&
                                      jobApplicationsSnapshot
                                          .data!.docs.isNotEmpty) {
                                    final jobApplicationDocs =
                                        jobApplicationsSnapshot.data!.docs;
                                    final jobApplicationDoc =
                                        jobApplicationDocs.first;
                                    final jobApplicationData =
                                        jobApplicationDoc.data();

                                    JobApplications jobApplication =
                                        JobApplications.fromJson(
                                            jobApplicationData);

                                    // pending, success, failed (job application)
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          top: 10.0, bottom: 15.0),
                                      child: UserNarrowButton(
                                        buttonText:
                                            jobApplication.applicationStatus,
                                        onPressed: () {},
                                        color: () {
                                          if (jobApplication
                                                  .applicationStatus ==
                                              "Success")
                                            return Colours.feedbackCorrectColor;
                                          else if (jobApplication
                                                  .applicationStatus ==
                                              "Failed")
                                            return Colours
                                                .feedbackIncorrectColor;
                                          else if (jobApplication
                                                  .applicationStatus ==
                                              "Pending")
                                            return Colours.primaryColor;
                                          else
                                            return Colours.primaryColor;
                                        }(),
                                        isSmallButton: false,
                                        iconPath: "",
                                      ),
                                    );
                                  } else {
                                    // job application is found but user has not applied
                                    if (job.applicantIsFound) {
                                      return const SizedBox();
                                    }
                                    // apply
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          top: 10.0, bottom: 15.0),
                                      child: UserNarrowButton(
                                        buttonText: "Apply",
                                        onPressed: () async {
                                          final connectionCheckerHelper =
                                              ConnectionCheckerHelper();
                                          bool hasConnection =
                                              await connectionCheckerHelper
                                                  .checkConnection();

                                          if (hasConnection) {
                                            setState(() {
                                              loading = true;
                                            });

                                            await addJobApplication();
                                          }
                                          // no wifi connection
                                          else {
                                            await showDialogPrompt(
                                              false,
                                              "Job Applied Failed",
                                              "assets/images/unsuccessful.png",
                                              "No WiFi connection",
                                            );
                                          }

                                          setState(() {
                                            loading = false;
                                          });
                                        },
                                        color: Colours.primaryColor,
                                        isSmallButton: false,
                                        iconPath: "",
                                      ),
                                    );
                                  }
                                });
                          }
                          // deleted job
                          else {
                            return const SizedBox();
                          }
                        }),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          );
  }

  Future<void> showDialogPrompt(bool isSuccess, String dialogTitle,
      String iconPath, String dialogMessage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            dialogTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.inputHintTextFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // image
              Container(
                child: Image.asset(
                  iconPath,
                  width: Images.feedbackLogoWidth,
                  height: Images.feedbackLogoHeight,
                ),
              ),
              const SizedBox(height: 20.0),
              // error text
              Container(
                child: Text(
                  dialogMessage,
                  style: const TextStyle(
                    fontFamily: Fonts.primaryFont,
                    fontSize: Fonts.inputHintTextFontSize,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            UserNarrowButton(
              buttonText: "OK",
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colours.primaryColor,
              isSmallButton: false,
              iconPath: "",
            ),
          ],
        );
      },
    );
  }

  Widget getJobImage(jobName) {
    String jobImagePath = "";

    switch (jobName) {
      case "Waiter":
        jobImagePath = "assets/images/recruiter/waiter.png";
        break;
      case "Cashier":
        jobImagePath = "assets/images/recruiter/cashier.png";
        break;
      case "Dish Washer":
        jobImagePath = "assets/images/recruiter/dish_washer.jpeg";
        break;
      case "Promoter":
        jobImagePath = "assets/images/recruiter/promoter.png";
        break;
      case "Cleaner":
        jobImagePath = "assets/images/recruiter/cleaner.png";
        break;
      default:
        jobImagePath = "assets/images/recruiter/waiter.png";
        break;
    }

    return Container(
      child: Image.asset(
        jobImagePath,
        width: Images.userNarrowJobIconWidth,
        height: Images.userNarrowJobIconHeight,
      ),
    );
  }

  String getGender(userGender) {
    String gender;

    switch (userGender) {
      case "Boy":
        gender = "Male";
        break;
      case "Girl":
        gender = "Female";
        break;
      default:
        gender = "";
        break;
    }

    return gender;
  }

  Widget getJobDescription(jobName) {
    switch (jobName) {
      case 'Waiter':
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Take Orders from Customers",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Serve Food and Beverages",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Handle Takeaway Packagings for Customers",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Clean and Reset Tables",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Assist Miscellaneous Tasks when Needed",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
      case 'Cashier':
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Handle Payments by Customers",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Handle Refunds for Customers",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Recommend Products for Customers",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Assist Miscellaneous Tasks when Needed",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
      case 'Dish Washer':
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Wash Dishes",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Sort and Store the Kitchen Utensils",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Maintain a Clean Kitchen Environment",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Assist Miscellaneous Tasks when Needed",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
      case 'Promoter':
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Engage with Customers to Promote and Recommend Products",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Perform Product Demonstrations and Provide Product Samples",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Set up Promotional Displays or Booths",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Assist Miscellaneous Tasks when Needed",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
      case 'Cleaner':
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Perform Cleaning Duties: Dusting, Sweeping, Mopping, Vacuuming",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Clean and Sanitize Work Environment",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Assist Miscellaneous Tasks when Needed",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
      default:
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "",
                style: TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
            ],
          ),
        );
    }
  }

  Future<void> addJobApplication() async {
    JobApplications jobApplication = JobApplications(
      jobApplicationId: "",
      userId: user.uid,
      jobId: widget.job.jobId,
      jobAppliedDateTime: DateTime.now().toUtc(),
      applicationStatus: "Pending",
    );

    try {
      final jobApplicationDoc = FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .doc();
      jobApplication.jobApplicationId = jobApplicationDoc.id;
      final json = jobApplication.toJson();
      await jobApplicationDoc.set(json);
      await deleteBookmarkJob(); // delete bookmark
    } catch (e) {
      await showDialogPrompt(
        false,
        "Job Applied Failed",
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  // delete bookmark after applying
  Future<void> deleteBookmarkJob() async {
    try {
      final bookmarkDocsSnapshot = await FirebaseFirestore.instance
          .collection(Bookmarks.collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('jobId', isEqualTo: widget.job.jobId)
          .limit(1)
          .get();

      if (bookmarkDocsSnapshot.docs.isNotEmpty) {
        final bookmarkDoc = bookmarkDocsSnapshot.docs.first;
        final bookmarkData = bookmarkDoc.data();

        // get the bookmark id
        String bookmarkDocId = bookmarkData['bookmarkId'];

        // delete the bookmark
        await FirebaseFirestore.instance
            .collection(Bookmarks.collectionName)
            .doc(bookmarkDocId)
            .delete();
      }

      await showDialogPrompt(
        true,
        "Job Applied Success",
        "assets/images/successful.png",
        "Job Applied Successful. Kindly wait for the recruiter to accept.",
      );
    } catch (e) {
      print(e);
    }
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
