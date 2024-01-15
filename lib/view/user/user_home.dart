import 'package:ckfyp02/model/jobs.dart';
import 'package:ckfyp02/view/user/user_job_details.dart';
import 'package:ckfyp02/view/user/user_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helper/connectionChecker.dart';
import '../../helper/scrollPhysics.dart';
import '../../model/bookmarks.dart';
import '../../model/job_applications.dart';
import '../layout/button.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
  final ConnectionCheckerHelper connectionCheckerHelper =
      ConnectionCheckerHelper();
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("h:mm a");
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // discover job row
        Container(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // discover jobs text
              const Expanded(
                child: Text(
                  "Discover Jobs",
                  style: TextStyle(
                    fontFamily: Fonts.primaryFont,
                    fontSize: Fonts.primaryTitleFontSize,
                  ),
                ),
              ),
              // search button
              Container(
                child: UserNarrowButton(
                  buttonText: "Search",
                  color: Colours.primaryColor,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserSearchView()));
                  },
                  isSmallButton: true,
                  iconPath: "assets/images/user/search.png",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        // job list view
        Expanded(
          // retrieve jobs
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Jobs.collectionName)
                .where('applicantIsFound', isEqualTo: false)
                .orderBy('jobPostedDateTime', descending: true)
                .snapshots(),
            builder: (context, jobsSnapshot) {
              // error
              if (jobsSnapshot.hasError) {
                return const Text('Error fetching details');
              }

              // waiting
              if (jobsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (jobsSnapshot.hasData && jobsSnapshot.data!.docs.isNotEmpty) {
                final jobDocs = jobsSnapshot.data!.docs;

                List<String> jobIdList = [];
                // retrieve job id list
                if (jobsSnapshot.hasData &&
                    jobsSnapshot.data!.docs.isNotEmpty) {
                  final jobDocs = jobsSnapshot.data!.docs;
                  for (QueryDocumentSnapshot doc in jobDocs) {
                    jobIdList.add(doc.id);
                  }
                }

                // retrieve bookmarks
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Bookmarks.collectionName)
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: ((context, bookmarksSnapshot) {
                    // error
                    if (bookmarksSnapshot.hasError) {
                      return const Text('Error fetching details');
                    }

                    List<String> bookmarkedJobsIdList = [];
                    // add all the bookmarked job ids into a list
                    if (bookmarksSnapshot.hasData &&
                        bookmarksSnapshot.data!.docs.isNotEmpty) {
                      final bookmarkDocs = bookmarksSnapshot.data!.docs;
                      for (var bookmarkDoc in bookmarkDocs) {
                        bookmarkedJobsIdList.add(bookmarkDoc.data()['jobId']);
                      }
                    } else {
                      // print("No bookmarks");
                    }

                    // retrieve job applications
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(JobApplications.collectionName)
                          .where('userId', isEqualTo: user.uid)
                          .where('applicationStatus',
                              whereIn: ['Pending', 'Failed']).snapshots(),
                      builder: (context, jobApplicationsSnapshot) {
                        // error
                        if (jobApplicationsSnapshot.hasError) {
                          return const Text('Error fetching details');
                        }

                        List<String> jobApplicationJobsIdList = [];
                        // add all the applied job ids into a list
                        if (jobApplicationsSnapshot.hasData &&
                            jobApplicationsSnapshot.data!.docs.isNotEmpty) {
                          final jobApplicationsDocs =
                              jobApplicationsSnapshot.data!.docs;
                          for (var jobApplicationDoc in jobApplicationsDocs) {
                            jobApplicationJobsIdList
                                .add(jobApplicationDoc.data()['jobId']);
                          }
                        } else {
                          // print("No Jobs Applied");
                        }

                        return ListView.builder(
                            itemCount: jobDocs.length,
                            controller: scrollController,
                            shrinkWrap: true,
                            physics: const  PositionRetainedScrollPhysics(),
                            itemBuilder: (context, index) {
                              // retrieve job information by iterating the jobDocs list
                              final jobDoc = jobDocs[index];
                              final jobData = jobDoc.data();
                              Jobs job = Jobs.fromJson(jobData);
                              bool isJobBookmarked =
                                  bookmarkedJobsIdList.contains(job.jobId);

                              int appliedCounter = 0;
                              // increment counter if jobs are applied
                              for (var i in jobIdList) {
                                if (jobApplicationJobsIdList.contains(i)) {
                                  appliedCounter++;
                                }
                              }

                              // if the jobs posted are applied
                              if (appliedCounter == jobDocs.length) {
                                if (index == jobDocs.length - 1) {
                                  // return 0 Jobs Posted text if all jobs are applied
                                  return const Center(
                                      child: Text("0 Jobs Available"));
                                }
                              }

                              // return empty if the job is already applied
                              if (jobApplicationJobsIdList
                                  .contains(job.jobId)) {
                                return const SizedBox();
                              }

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
                                                    recruiterId:
                                                        job.recruiterId,
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
                                                    50.0,
                                                  ),
                                                  blurRadius: 15.0,
                                                  spreadRadius: 0.1,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // image
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    child: getJobImage(
                                                        job.jobName),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // job name
                                                        Text(
                                                          job.jobName,
                                                          style: const TextStyle(
                                                              fontFamily: Fonts
                                                                  .primaryFont,
                                                              fontSize: Fonts
                                                                  .cardTitleFontSize,
                                                              color: Colours
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
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
                                                              Icons
                                                                  .location_city,
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
                                                                      fontFamily:
                                                                          Fonts
                                                                              .primaryFont,
                                                                      fontSize:
                                                                          Fonts
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
                                                                      fontFamily:
                                                                          Fonts
                                                                              .primaryFont,
                                                                      fontSize:
                                                                          Fonts
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
                                                                      fontFamily:
                                                                          Fonts
                                                                              .primaryFont,
                                                                      fontSize:
                                                                          Fonts
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
                                                        // job pay
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
                                                        // job posted date
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Posted: ',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily: Fonts
                                                                    .primaryFont,
                                                                fontSize: Fonts
                                                                    .primaryFontSize,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                dateFormatter
                                                                    .format(job
                                                                        .jobPostedDateTime)
                                                                    .toString(),
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
                                  // bookmark button
                                  GestureDetector(
                                    onTap: () async {
                                      String bookmarkId = "";
                                      // retrieve the bookmark id, else assign it in addBookmarkJob
                                      for (var doc
                                          in bookmarksSnapshot.data!.docs) {
                                        if (doc.data()['jobId'] == job.jobId) {
                                          bookmarkId = doc.id;
                                          break;
                                        }
                                      }

                                      final bookmark = Bookmarks(
                                        bookmarkId: bookmarkId,
                                        userId: user.uid,
                                        jobId: job.jobId,
                                        bookmarkAddedDateTime:
                                            DateTime.now().toUtc(),
                                      );

                                      // if bookmarked, delete
                                      if (isJobBookmarked) {
                                        deleteBookmarkJob(bookmark);
                                      }
                                      // if not bookmarked, add
                                      else {
                                        addBookmarkJob(bookmark);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.0,
                                      decoration: const BoxDecoration(
                                        color: Colours.primaryColor,
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.black,
                                            width: 0.4755,
                                          ),
                                          right: BorderSide(
                                            color: Colors.black,
                                            width: 0.75,
                                          ),
                                          bottom: BorderSide(
                                            color: Colors.black,
                                            width: 0.75,
                                          ),
                                        ),
                                      ),
                                      child: getBookmarkBar(isJobBookmarked),
                                    ),
                                  ),

                                  // item separator
                                  const SizedBox(height: 30.0),
                                ],
                              );
                            });
                      },
                    );
                    // });
                  }),
                );
              } else {
                return const Align(
                    alignment: Alignment.topCenter,
                    child: Text("0 Jobs Available"));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget getBookmarkBar(isJobBookmarked) {
    String bookmarkText;
    IconData bookmarkIcon;

    if (isJobBookmarked) {
      bookmarkText = "Remove Bookmark";
      bookmarkIcon = Icons.bookmark_outlined;
    } else {
      bookmarkText = "Bookmark";
      bookmarkIcon = Icons.bookmark_outline;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          bookmarkIcon,
          size: Images.userNarrowIconWidth,
        ),
        Text(
          bookmarkText,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: Fonts.primaryFont,
            fontSize: Fonts.primaryFontSize,
          ),
        ),
      ],
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

  Future addBookmarkJob(Bookmarks bookmark) async {
    try {
      final bookmarkDoc =
          FirebaseFirestore.instance.collection(Bookmarks.collectionName).doc();
      bookmark.bookmarkId = bookmarkDoc.id;
      final json = bookmark.toJson();
      await bookmarkDoc.set(json);
    } catch (e) {
      // debug
      print(e);
    }
  }

  Future deleteBookmarkJob(Bookmarks bookmark) async {
    try {
      final bookmarkDoc = FirebaseFirestore.instance
          .collection(Bookmarks.collectionName)
          .doc(bookmark.bookmarkId);
      bookmarkDoc.delete();
    } catch (e) {
      // debug
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
