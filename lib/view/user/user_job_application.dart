import 'package:ckfyp02/model/job_applications.dart';
import 'package:ckfyp02/view/user/user_job_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/jobs.dart';
import '../../model/recruiters.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';

class UserJobApplicationView extends StatefulWidget {
  const UserJobApplicationView({super.key});

  @override
  State<UserJobApplicationView> createState() => _UserJobApplicationViewState();
}

class _UserJobApplicationViewState extends State<UserJobApplicationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Job Application"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // remove appbar back button
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(),
          wideLayout: WideLayout(),
        ),
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  const NarrowLayout({super.key});

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User user = FirebaseAuth.instance.currentUser!;
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("h:mm a");
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // retrieve job applications
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(JobApplications.collectionName)
            .where('userId', isEqualTo: user.uid)
            .orderBy('jobAppliedDateTime', descending: true)
            .snapshots(),
        builder: (context, jobApplicationsSnapshot) {
          // error
          if (jobApplicationsSnapshot.hasError) {
            return const Text('Error fetching details');
          }

          // waiting
          if (jobApplicationsSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobApplicationsSnapshot.hasData &&
              jobApplicationsSnapshot.data!.docs.isNotEmpty) {
            final jobApplicationDocs = jobApplicationsSnapshot.data!.docs;

            // retrieve job
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(Jobs.collectionName)
                    .snapshots(),
                builder: (context, jobsSnapshot) {
                  // error
                  if (jobsSnapshot.hasError) {
                    return const Text('Error fetching details');
                  }
                  if (jobsSnapshot.hasData &&
                      jobsSnapshot.data!.docs.isNotEmpty) {
                    final jobDocs = jobsSnapshot.data!.docs;

                    List<String> jobIdList = [];
                    for (var jobDoc in jobDocs) {
                      jobIdList.add(jobDoc.data()['jobId']);
                    }

                    // UI
                    return ListView.builder(
                        itemCount: jobApplicationDocs.length,
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          final jobApplicationDoc = jobApplicationDocs[index];
                          final jobApplicationData = jobApplicationDoc.data();
                          final jobApplication =
                              JobApplications.fromJson(jobApplicationData);
                          final jobIndex = jobIdList.indexWhere(
                              (item) => item == jobApplication.jobId);

                          if (jobIndex == -1) {
                            return const SizedBox();
                          }

                          final jobData = jobDocs[jobIndex].data();
                          final job = Jobs.fromJson(jobData);

                          // UI
                          return Column(
                            children: [
                              // card
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserJobDetailsView(
                                                job: job,
                                                recruiterId: job.recruiterId,
                                              )));
                                },
                                child: Container(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      // brief job details
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 20.0, bottom: 10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(width: 0.75),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(
                                                2.5,
                                                5.0,
                                              ),
                                              blurRadius: 15.0,
                                              spreadRadius: 0.1,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // image
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: getJobImage(job.jobName),
                                              ),
                                            ),
                                            //details
                                            Expanded(
                                              flex: 6,
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // job name
                                                    Text(
                                                      job.jobName,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              Fonts.primaryFont,
                                                          fontSize: Fonts
                                                              .cardTitleFontSize,
                                                          color: Colours
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                        height: 15.0),
                                                    // business
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // icon
                                                        const Icon(
                                                          Icons.location_city,
                                                          size: Images
                                                              .userNarrowIconWidth,
                                                          color: Colours
                                                              .secondaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 5.0),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                job.businessName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily: Fonts
                                                                      .primaryFont,
                                                                  fontSize: Fonts
                                                                      .primaryFontSize,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 2.5,
                                                              ),
                                                              Text(
                                                                job.states,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily: Fonts
                                                                      .primaryFont,
                                                                  fontSize: Fonts
                                                                      .primaryFontSize,
                                                                  color: Colours
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 15.0),
                                                    // job time
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // icon
                                                        const Icon(
                                                          Icons.date_range,
                                                          size: Images
                                                              .userNarrowIconWidth,
                                                          color: Colours
                                                              .secondaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 5.0),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                ("${timeFormatter.format(job.jobStartTime)} - ${timeFormatter.format(job.jobEndTime)}"),
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily: Fonts
                                                                      .primaryFont,
                                                                  fontSize: Fonts
                                                                      .primaryFontSize,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 15.0),
                                                    // joy pay
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.money,
                                                          size: Images
                                                              .userNarrowIconWidth,
                                                          color: Colours
                                                              .secondaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 5.0),
                                                        Expanded(
                                                          child: Text(
                                                            ('RM ${job.jobPay.toStringAsFixed(2)} (${(job.jobEndTime.difference(job.jobStartTime).inMinutes / 60).toStringAsFixed(1)} hours)'),
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: Fonts
                                                                  .primaryFont,
                                                              fontSize: Fonts
                                                                  .primaryFontSize,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 15.0),
                                                    // joy application status
                                                    getApplicationStatusText(
                                                        jobApplication
                                                            .applicationStatus),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30.0)
                            ],
                          );
                        });
                  }
                  return const Align(
                      alignment: Alignment.topCenter,
                      child: Text("0 Jobs Applied"));
                });
          } else {
            return const Align(
                alignment: Alignment.topCenter, child: Text("0 Jobs Applied"));
          }
        });
  }

  Widget getApplicationStatusText(jobApplicationStatus) {
    Color textColor;

    switch (jobApplicationStatus) {
      case 'Pending':
        textColor = Colours.primaryColor;
        break;
      case 'Failed':
        textColor = Colours.feedbackIncorrectColor;
        break;
      case 'Success':
        textColor = Colours.feedbackCorrectColor;
        break;
      default:
        textColor = Colours.primaryColor;
        break;
    }

    return Text(
      jobApplicationStatus.toUpperCase(),
      style: TextStyle(
        fontFamily: Fonts.primaryFont,
        fontSize: Fonts.primaryFontSize,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
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
        width: Images.userNarrowCardIconWidth,
        height: Images.userNarrowCardIconHeight,
      ),
    );
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
