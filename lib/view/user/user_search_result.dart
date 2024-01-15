import 'dart:async';
import 'package:ckfyp02/model/recruiters.dart';
import 'package:ckfyp02/view/user/user_job_details.dart';
import 'package:ckfyp02/view/user/user_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helper/scrollPhysics.dart';
import '../../model/bookmarks.dart';
import '../../model/job_applications.dart';
import '../../model/jobs.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/input_field.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';

class UserSearchResultView extends StatefulWidget {
  final String searchText;

  UserSearchResultView({
    required this.searchText,
  });

  @override
  State<UserSearchResultView> createState() => _UserSearchResultViewState();
}

class _UserSearchResultViewState extends State<UserSearchResultView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(searchText: widget.searchText),
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
}

class NarrowLayout extends StatefulWidget {
  String searchText;

  NarrowLayout({required this.searchText});

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final searchController = TextEditingController();
  final List<String> malaysiaStates = [
    'None',
    'Johor',
    'Kedah',
    'Kelantan',
    'Perak',
    'Selangor',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Perlis',
    'Penang',
    'Sabah',
    'Sarawak',
    'Terengganu',
  ];
  String selectedStatesValue = "";

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    String searchResult = widget.searchText;

    return Column(
      children: [
        // search bar and filter button
        Container(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // search bar
              Expanded(
                child: Container(
                  child: UserNarrowSearchBar(
                    controller: searchController,
                    textCapitalization: TextCapitalization.words,
                    hintText: searchResult,
                    isReadOnly: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 5.0),
              // filter button
              Container(
                child: UserNarrowButton(
                  buttonText: "Filter",
                  color: Colours.primaryColor,
                  onPressed: () async {
                    showStatesDialog().then((value) {
                      setState(() {
                        selectedStatesValue = value;
                      });
                    });
                  },
                  isSmallButton: true,
                  iconPath: "assets/images/user/filter.png",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        Container(
          margin: const EdgeInsets.only(
            left: 5.0,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              selectedStatesValue == ""
                  ? 'Filter Applied: None'
                  : 'Filter Applied: $selectedStatesValue',
              style: const TextStyle(
                fontFamily: Fonts.primaryFont,
                fontSize: Fonts.primaryFontSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        // list view
        Expanded(
          // retrieve job by jobName
          child: StreamBuilder(
            stream: (selectedStatesValue == "" || selectedStatesValue == "None")
                ? FirebaseFirestore.instance
                    .collection(Jobs.collectionName)
                    .where('jobName', isGreaterThanOrEqualTo: searchResult)
                    .where('jobName',
                        isLessThanOrEqualTo: searchResult + '\uf8ff')
                    .where('applicantIsFound', isEqualTo: false)
                    .orderBy('jobName')
                    .orderBy('jobPostedDateTime', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection(Jobs.collectionName)
                    .where('jobName', isGreaterThanOrEqualTo: searchResult)
                    .where('jobName',
                        isLessThanOrEqualTo: searchResult + '\uf8ff')
                    .where('states', isEqualTo: selectedStatesValue)
                    .where('applicantIsFound', isEqualTo: false)
                    .orderBy('jobName')
                    .orderBy('jobPostedDateTime', descending: true)
                    .snapshots(),
            builder: (context, jobsSnapshot) {
              // error
              if (jobsSnapshot.hasError) {
                return const Text('Error fetching details');
              }

              Map<String, DateTime> jobIdMap = {};

              if (jobsSnapshot.hasData && jobsSnapshot.data!.docs.isNotEmpty) {
                final jobDocs2 = jobsSnapshot.data!.docs;

                for (var doc in jobDocs2) {
                  jobIdMap[doc.id] =
                      (doc.data()['jobPostedDateTime'] as Timestamp).toDate();
                }
              }

              // retrieve job by business name
              return StreamBuilder(
                  stream: (selectedStatesValue == "" ||
                          selectedStatesValue == "None")
                      ? FirebaseFirestore.instance
                          .collection(Jobs.collectionName)
                          .where('businessName',
                              isGreaterThanOrEqualTo: searchResult)
                          .where('businessName',
                              isLessThanOrEqualTo: searchResult + '\uf8ff')
                          .where('applicantIsFound', isEqualTo: false)
                          .orderBy('businessName')
                          .orderBy('jobPostedDateTime', descending: true)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection(Jobs.collectionName)
                          .where('businessName',
                              isGreaterThanOrEqualTo: searchResult)
                          .where('businessName',
                              isLessThanOrEqualTo: searchResult + '\uf8ff')
                          .where('states', isEqualTo: selectedStatesValue)
                          .where('applicantIsFound', isEqualTo: false)
                          .orderBy('businessName')
                          .orderBy('jobPostedDateTime', descending: true)
                          .snapshots(),
                  builder: (context, jobsSnapshot2) {
                    if (jobsSnapshot2.hasData &&
                        jobsSnapshot2.data!.docs.isNotEmpty) {
                      final jobDocs3 = jobsSnapshot2.data!.docs;

                      for (var doc in jobDocs3) {
                        jobIdMap[doc.id] =
                            (doc.data()['jobPostedDateTime'] as Timestamp)
                                .toDate();
                      }
                    }

                    // empty search result
                    if (jobIdMap.isEmpty) {
                      return const Text("0 Jobs Available");
                    }

                    // retrieve bookmark
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(Bookmarks.collectionName)
                            .where('userId', isEqualTo: user.uid)
                            .snapshots(),
                        builder: (context, bookmarksSnapshot) {
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
                              bookmarkedJobsIdList
                                  .add(bookmarkDoc.data()['jobId']);
                            }
                          }

                          // retrieve job applications
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection(JobApplications.collectionName)
                                  .where('userId', isEqualTo: user.uid)
                                  .where('applicationStatus', whereIn: [
                                'Pending',
                                'Failed'
                              ]).snapshots(),
                              builder: (context, jobApplicationsSnapshot) {
                                // error
                                if (jobApplicationsSnapshot.hasError) {
                                  return const Text('Error fetching details');
                                }

                                List<String> jobApplicationJobsIdList = [];
                                if (jobApplicationsSnapshot.hasData &&
                                    jobApplicationsSnapshot
                                        .data!.docs.isNotEmpty) {
                                  final jobApplicationsDocs =
                                      jobApplicationsSnapshot.data!.docs;
                                  for (var doc in jobApplicationsDocs) {
                                    jobApplicationJobsIdList
                                        .add(doc.data()['jobId']);
                                  }
                                }

                                List<String> jobIdList = sortMap(jobIdMap);

                                return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection(Jobs.collectionName)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    // error
                                    if (snapshot.hasError) {
                                      return const Text(
                                          'Error fetching details');
                                    }

                                    if (snapshot.hasData &&
                                        snapshot.data!.docs.isNotEmpty) {
                                      final jobDocs = snapshot.data!.docs;
                                      List<String> allJobsIdList = [];
                                      for (var jobDoc in jobDocs) {
                                        allJobsIdList
                                            .add(jobDoc.data()['jobId']);
                                      }

                                      return displayListView(
                                          user,
                                          jobDocs,
                                          allJobsIdList,
                                          jobIdList,
                                          bookmarksSnapshot,
                                          bookmarkedJobsIdList,
                                          jobApplicationJobsIdList);
                                    } else {
                                      return const Align(
                                          alignment: Alignment.topCenter,
                                          child: Text("0 Jobs Available"));
                                    }
                                  },
                                );
                              });
                        });
                  });
            },
          ),
        ),
      ],
    );
  }

  // sort the map by value in desc order
  // return the map keys in list
  List<String> sortMap(Map<String, DateTime> jobIdMap) {
    List<MapEntry<String, DateTime>> sortedMapEntries =
        jobIdMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    List<String> jobIdList =
        sortedMapEntries.map((entry) => entry.key).toList();

    return jobIdList;
  }

  Widget displayListView(user, jobDocs, allJobsIdList, jobIdList,
      bookmarksSnapshot, bookmarkedJobsIdList, jobApplicationJobsIdList) {
    DateFormat dateFormatter = DateFormat("y-MM-dd");
    DateFormat timeFormatter = DateFormat("h:mm a");
    final ScrollController scrollController = ScrollController();

    // iterate over the sorted list
    return ListView.builder(
      itemCount: jobIdList.length,
      shrinkWrap: true,
      controller: scrollController,
      physics: const PositionRetainedScrollPhysics(),
      itemBuilder: (context, index) {
        final jobIndex =
            allJobsIdList.indexWhere((item) => item == jobIdList[index]);

        if (jobIndex == -1) {
          return const SizedBox();
        }

        final jobData = jobDocs[jobIndex].data();
        final job = Jobs.fromJson(jobData);

        bool isJobBookmarked = bookmarkedJobsIdList.contains(job.jobId);

        int appliedCounter = 0;
        // increment counter if jobs are applied
        for (var i in jobIdList) {
          if (jobApplicationJobsIdList.contains(i)) {
            appliedCounter++;
          }
        }

        // if the jobs posted are applied
        if (appliedCounter == jobIdList.length) {
          if (index == jobIdList.length - 1) {
            // return 0 Jobs Posted text if all jobs are applied
            return const Center(child: Text("0 Jobs Available"));
          }
        }

        // return empty if the job is already applied
        if (jobApplicationJobsIdList.contains(job.jobId)) {
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
                        builder: (context) => UserJobDetailsView(
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
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 0.75,
                        ),
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
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // job name
                                  Text(
                                    job.jobName,
                                    style: const TextStyle(
                                        fontFamily: Fonts.primaryFont,
                                        fontSize: Fonts.cardTitleFontSize,
                                        color: Colours.primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15.0),
                                  // business
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            Text(
                                              job.businessName,
                                              style: const TextStyle(
                                                fontFamily: Fonts.primaryFont,
                                                fontSize: Fonts.primaryFontSize,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2.5,
                                            ),
                                            Text(
                                              job.states,
                                              style: const TextStyle(
                                                fontFamily: Fonts.primaryFont,
                                                fontSize: Fonts.primaryFontSize,
                                                color: Colours.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15.0),
                                  // job time
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              ("${timeFormatter.format(job.jobStartTime)} - ${timeFormatter.format(job.jobEndTime)}"),
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
                                  const SizedBox(height: 15.0),
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
                                          ('RM ${job.jobPay.toStringAsFixed(2)} (${(job.jobEndTime.difference(job.jobStartTime).inMinutes / 60).toStringAsFixed(1)} hours)'),
                                          style: const TextStyle(
                                            fontFamily: Fonts.primaryFont,
                                            fontSize: Fonts.primaryFontSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15.0),
                                  // job posted date
                                  Row(
                                    children: [
                                      const Text(
                                        'Posted: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Fonts.primaryFont,
                                          fontSize: Fonts.primaryFontSize,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          dateFormatter
                                              .format(job.jobPostedDateTime)
                                              .toString(),
                                          style: const TextStyle(
                                            fontFamily: Fonts.primaryFont,
                                            fontSize: Fonts.primaryFontSize,
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
              onTap: () {
                String bookmarkId = "";
                // retrieve the bookmark id from bookmark snapshot for deletion
                for (var doc in bookmarksSnapshot.data!.docs) {
                  if (doc.data()['jobId'] == job.jobId) {
                    bookmarkId = doc.id;
                    break;
                  }
                }

                final bookmark = Bookmarks(
                  bookmarkId: bookmarkId,
                  userId: user.uid,
                  jobId: job.jobId,
                  bookmarkAddedDateTime: DateTime.now(),
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
                      width: 0.75,
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
      },
    );
  }

  Future<String> showStatesDialog() async {
    int? selectedIndex = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select State'),
            children: getStatesOptions(),
          );
        });

    if (selectedIndex != null) {
      setState(() {
        selectedStatesValue = malaysiaStates[selectedIndex];
      });
      return malaysiaStates[selectedIndex];
    }
    return "";
  }

  List<Widget> getStatesOptions() {
    List<Widget> statesOptions = [];
    for (int i = 0; i < malaysiaStates.length; i++) {
      statesOptions.add(
        SimpleDialogOption(
          child: Text(malaysiaStates[i]),
          onPressed: () {
            Navigator.pop(context, i);
          },
        ),
      );
    }
    return statesOptions;
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
