import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/model/job_applications.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/recruiter/recruiter_employee.dart';
import 'package:ckfyp02/view/recruiter/recruiter_home.dart';
import 'package:ckfyp02/view/recruiter/recruiter_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../../helper/connectionChecker.dart';
import '../../helper/languageConverter.dart';
import '../../helper/languagePreferences.dart';
import '../../helper/scrollPhysics.dart';
import '../../model/bookmarks.dart';
import '../../model/jobs.dart';
import '../../model/language.dart';
import '../../model/users.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:url_launcher/url_launcher.dart';

class RecruiterApplicantsListView extends StatefulWidget {
  Jobs job;

  RecruiterApplicantsListView({
    required this.job,
  });

  @override
  State<RecruiterApplicantsListView> createState() =>
      _RecruiterApplicantsListViewState();
}

class _RecruiterApplicantsListViewState
    extends State<RecruiterApplicantsListView> {
  int currentIndex = -1;
  final audioPlayer = AudioPlayer();
  String audioPath = "";
  LanguagePreferencesHelper languagePreferencesHelper =
      LanguagePreferencesHelper();
  String language = "";

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/recruiter/job.png",
              width: Images.recrNarrowIconWidth,
              height: Images.recrNarrowIconHeight,
            ),
            Image.asset(
              "assets/images/recruiter/boy.png",
              width: Images.recrNarrowIconWidth,
              height: Images.recrNarrowIconHeight,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          LanguageDropDownMenu(
            onChanged: (lang) async {
              await languagePreferencesHelper
                  .setSelectedLanguage(lang.toString());
              setState(() {
                language = lang!;
              });
              audioPlayer.dispose();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(
            job: widget.job,
            audioPlayer: audioPlayer,
            language: language,
            getLanguage: getLanguage,
          ),
          wideLayout: WideLayout(),
        ),
      ),
      bottomNavigationBar: RecrBottomNavBarView(
        isAtMainPage: true,
        language: language,
        onTap: (int index) async {
          switch (index) {
            case 0:
              audioPlayer.dispose();
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecruiterHomeView()))
                  .then((value) => getLanguage());
              break;
            case 1:
              audioPlayer.dispose();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                SystemNavigator.pop();
              }
              break;
            case 2:
              double deviceVolume = await PerfectVolumeControl.getVolume();

              if (deviceVolume <= 0.3) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/recruiter/increase.png",
                                  width: Images.feedbackLogoWidth,
                                  height: Images.feedbackLogoHeight,
                                ),
                                Image.asset(
                                  "assets/images/recruiter/audio.png",
                                  width: Images.feedbackLogoWidth,
                                  height: Images.feedbackLogoHeight,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20.0),
                            // error text
                            Text(
                              LanguageConverterHelper.getIncreaseAudioTextLang(
                                  language),
                              style: const TextStyle(
                                fontFamily: Fonts.primaryFont,
                                fontSize: Fonts.inputHintTextFontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: [
                          RecrNarrowButton(
                            buttonText: "OK",
                            isSmallButton: false,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colours.primaryColor,
                            iconPath: "assets/images/recruiter/ok.png",
                          ),
                        ],
                      );
                    },
                  );
                }
              } else {
                if (language == Language.english) {
                  audioPath = "audio/en/applicant_list.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/applicant_list.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/applicant_list.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/applicant_list.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                }
              }

              break;
            case 3:
              audioPlayer.dispose();
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecruiterProfileView()))
                  .then((value) => getLanguage());
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Future<void> getLanguage() async {
    String selectedLang = await languagePreferencesHelper.getSelectedLanguage();

    setState(() {
      language = selectedLang;
    });
  }
}

class NarrowLayout extends StatefulWidget {
  Jobs job;
  final AudioPlayer audioPlayer;
  final String language;
  final VoidCallback getLanguage;

  NarrowLayout({
    required this.job,
    required this.audioPlayer,
    required this.language,
    required this.getLanguage,
  });

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User recruiter = FirebaseAuth.instance.currentUser!;
  ScrollController scrollbarController = ScrollController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingView()
        : Column(
            children: [
              // title row
              Container(
                width: double.infinity,
                child: Container(
                  child: Row(
                    children: [
                      // image
                      Container(
                        child: Image.asset(
                          "assets/images/recruiter/job.png",
                          width: Images.recrNarrowIconWidth,
                          height: Images.recrNarrowIconHeight,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // image
                      Container(
                        child: Image.asset(
                          "assets/images/recruiter/boy.png",
                          width: Images.recrNarrowIconWidth,
                          height: Images.recrNarrowIconHeight,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // text
                      Expanded(
                        child: Container(
                          child: Text(
                            LanguageConverterHelper
                                .getApplicantsListTitleTextLang(
                                    widget.language),
                            style: const TextStyle(
                              fontFamily: Fonts.primaryFont,
                              fontSize: Fonts.primaryRecrTitleFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // job applicants list view
              Expanded(
                // retrieve job application
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(JobApplications.collectionName)
                        .where('jobId', isEqualTo: widget.job.jobId)
                        .where('applicationStatus', isEqualTo: "Pending")
                        .orderBy('jobAppliedDateTime')
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
                        final jobApplicantDocs =
                            jobApplicationsSnapshot.data!.docs;

                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(Users.collectionName)
                                .snapshots(),
                            builder: (context, usersSnapshot) {
                              // error
                              if (usersSnapshot.hasError) {
                                return const Text('Error fetching details');
                              }

                              if (usersSnapshot.hasData &&
                                  usersSnapshot.data!.docs.isNotEmpty) {
                                List<String> userIdList = [];
                                // retrieve job id list

                                final userDocs = usersSnapshot.data!.docs;
                                for (QueryDocumentSnapshot doc in userDocs) {
                                  userIdList.add(doc.id);
                                }

                                return Scrollbar(
                                  thumbVisibility: true,
                                  thickness: 10.0,
                                  controller: scrollbarController,
                                  child: ListView.builder(
                                      itemCount: jobApplicantDocs.length,
                                      controller: scrollbarController,
                                      shrinkWrap: true,
                                      physics:
                                          const PositionRetainedScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final jobApplicationDoc =
                                            jobApplicantDocs[index];
                                        final jobApplicantionData =
                                            jobApplicationDoc.data();
                                        final jobApplication =
                                            JobApplications.fromJson(
                                                jobApplicantionData);

                                        final userIndex = userIdList.indexWhere(
                                            (item) =>
                                                item == jobApplication.userId);

                                        if (userIndex == -1) {
                                          return const SizedBox();
                                        }

                                        final userData =
                                            userDocs[userIndex].data();
                                        final userDetails =
                                            Users.fromJson(userData);
                                        // UI
                                        return Column(
                                          children: [
                                            const SizedBox(height: 5.0),
                                            Container(
                                              width: double.infinity,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border:
                                                      Border.all(width: 1.5),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      offset: Offset(
                                                        5.0,
                                                        2.0,
                                                      ),
                                                      blurRadius: 15.0,
                                                      spreadRadius: 0.1,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0,
                                                              bottom: 20.0),
                                                      child: Row(
                                                        children: [
                                                          // image
                                                          Expanded(
                                                            flex: 4,
                                                            child: Center(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl:
                                                                    userDetails
                                                                        .image,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    const CircularProgressIndicator(),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  child: Image
                                                                      .asset(
                                                                    getApplicantGenderImage(
                                                                        userDetails
                                                                            .gender),
                                                                    width: Images
                                                                        .userNarrowCardIconWidth,
                                                                    height: Images
                                                                        .userNarrowCardIconHeight,
                                                                  ),
                                                                ),
                                                                width: Images
                                                                        .recrNarrowProfileIconWidth +
                                                                    20,
                                                                height: Images
                                                                        .recrNarrowProfileIconHeight +
                                                                    20,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10.0),
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
                                                                  // name
                                                                  Text(
                                                                    userDetails
                                                                        .name,
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            Fonts
                                                                                .primaryFont,
                                                                        fontSize:
                                                                            Fonts
                                                                                .cardRecrTitleFontSize,
                                                                        color: Colours
                                                                            .primaryColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20.0),
                                                                  // mobile num
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/images/recruiter/phone_number.png",
                                                                        width: Images
                                                                            .recrNarrowSmallIconWidth,
                                                                        height:
                                                                            Images.recrNarrowSmallIconHeight,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            final Uri
                                                                                call =
                                                                                Uri(scheme: "tel", path: userDetails.mobileNum);

                                                                            if (await canLaunchUrl(call)) {
                                                                              launchUrl(call);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            userDetails.mobileNum,
                                                                            style:
                                                                                const TextStyle(
                                                                              fontFamily: Fonts.primaryFont,
                                                                              fontSize: Fonts.primaryRecrFontSize,
                                                                              color: Colours.primaryColor,
                                                                              fontWeight: FontWeight.bold,
                                                                              decoration: TextDecoration.underline,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20.0),
                                                                  // gender
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        getApplicantGenderImage(
                                                                            userDetails.gender),
                                                                        width: Images
                                                                            .recrNarrowSmallIconWidth,
                                                                        height:
                                                                            Images.recrNarrowSmallIconHeight,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          LanguageConverterHelper.getGenderLang(
                                                                              widget.language,
                                                                              userDetails.gender),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontFamily:
                                                                                Fonts.primaryFont,
                                                                            fontSize:
                                                                                Fonts.primaryRecrFontSize,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20.0),
                                                                  // age
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/images/recruiter/age.png",
                                                                        width: Images
                                                                            .recrNarrowSmallIconWidth,
                                                                        height:
                                                                            Images.recrNarrowSmallIconHeight,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          ('${(DateTime.now().year - userDetails.birthDate.year).toStringAsFixed(0)} ${LanguageConverterHelper.getAgeTextLang(widget.language)} '),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontFamily:
                                                                                Fonts.primaryFont,
                                                                            fontSize:
                                                                                Fonts.primaryRecrFontSize,
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
                                                    // accept and reject
                                                    Container(
                                                      height: 70.0,
                                                      color:
                                                          Colours.primaryColor,
                                                      child: Row(
                                                        // mainAxisAlignment:
                                                        //     MainAxisAlignment
                                                        //         .spaceEvenly,
                                                        // crossAxisAlignment:
                                                        //     CrossAxisAlignment
                                                        //         .center,
                                                        children: [
                                                          // accept button
                                                          Expanded(
                                                            flex: 5,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                widget
                                                                    .audioPlayer
                                                                    .dispose();

                                                                final connectionCheckerHelper =
                                                                    ConnectionCheckerHelper();
                                                                bool
                                                                    hasConnection =
                                                                    await connectionCheckerHelper
                                                                        .checkConnection();

                                                                if (hasConnection) {
                                                                  setState(() {
                                                                    loading =
                                                                        true;
                                                                  });

                                                                  await acceptApplicant(
                                                                      widget
                                                                          .job,
                                                                      userDetails,
                                                                      jobApplication);
                                                                } else {
                                                                  await showDialogPrompt(
                                                                    false,
                                                                    "assets/images/unsuccessful.png",
                                                                    LanguageConverterHelper
                                                                        .getNoWifiTextLang(
                                                                            widget.language),
                                                                  );
                                                                }

                                                                setState(() {
                                                                  loading =
                                                                      false;
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Image
                                                                        .asset(
                                                                      "assets/images/successful.png",
                                                                      width: Images
                                                                          .userNarrowCardIconWidth,
                                                                      height: Images
                                                                          .userNarrowCardIconHeight,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5.0,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      LanguageConverterHelper.getAcceptTextLang(
                                                                          widget
                                                                              .language),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            Fonts.primaryFont,
                                                                        fontSize:
                                                                            Fonts.primaryRecrFontSize,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          // divider
                                                          Container(
                                                            width: 3.0,
                                                            color: Colors.white,
                                                          ),
                                                          // reject button
                                                          Expanded(
                                                            flex: 5,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () async {
                                                                widget
                                                                    .audioPlayer
                                                                    .dispose();
                                                                final connectionCheckerHelper =
                                                                    ConnectionCheckerHelper();
                                                                bool
                                                                    hasConnection =
                                                                    await connectionCheckerHelper
                                                                        .checkConnection();

                                                                if (hasConnection) {
                                                                  setState(() {
                                                                    loading =
                                                                        true;
                                                                  });

                                                                  await rejectApplicant(
                                                                      widget
                                                                          .job,
                                                                      userDetails);
                                                                } else {
                                                                  await showDialogPrompt(
                                                                    false,
                                                                    "assets/images/unsuccessful.png",
                                                                    LanguageConverterHelper
                                                                        .getNoWifiTextLang(
                                                                            widget.language),
                                                                  );
                                                                }

                                                                setState(() {
                                                                  loading =
                                                                      false;
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Image
                                                                        .asset(
                                                                      "assets/images/unsuccessful.png",
                                                                      width: Images
                                                                          .userNarrowCardIconWidth,
                                                                      height: Images
                                                                          .userNarrowCardIconHeight,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 5.0,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      LanguageConverterHelper.getRejectTextLang(
                                                                          widget
                                                                              .language),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            Fonts.primaryFont,
                                                                        fontSize:
                                                                            Fonts.primaryRecrFontSize,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
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
                                            const SizedBox(height: 30.0),
                                          ],
                                        );
                                      }),
                                );
                              }
                              // 0 Applicants
                              else {
                                return Center(
                                  child: Text(LanguageConverterHelper
                                      .getZeroApplicantsPostedTextLang(
                                          widget.language)),
                                );
                              }
                            });
                      }
                      // 0 applicants
                      else {
                        return Text(LanguageConverterHelper
                            .getZeroApplicantsPostedTextLang(widget.language));
                      }
                    }),
              ),
            ],
          );
  }

  Future<void> showDialogPrompt(
      bool isSuccess, String iconPath, String dialogMessage,
      {JobApplications? jobApplication}) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
              RecrNarrowButton(
                buttonText: "OK",
                isSmallButton: false,
                onPressed: () {
                  if (isSuccess) {
                    Navigator.of(context).pop();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecruiterEmployeeView(
                                  jobApplication: jobApplication!,
                                )));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                color: Colours.primaryColor,
                iconPath: "assets/images/recruiter/ok.png",
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  String getApplicantGenderImage(gender) {
    String iconPath;
    if (gender == "Boy") {
      iconPath = "assets/images/recruiter/boy.png";
    } else {
      iconPath = "assets/images/recruiter/girl.png";
    }

    return iconPath;
  }

  Future<void> acceptApplicant(
      Jobs job, Users user, JobApplications jobApplication) async {
    await deleteBookmarks(job, user, jobApplication);
  }

  Future<void> deleteBookmarks(
      Jobs job, Users user, JobApplications jobApplication) async {
    try {
      final bookmarkSnapshots = await FirebaseFirestore.instance
          .collection(Bookmarks.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .get();

      if (bookmarkSnapshots.docs.isNotEmpty) {
        final bookmarkDocs = bookmarkSnapshots.docs;

        for (QueryDocumentSnapshot bookmarkDoc in bookmarkDocs) {
          String bookmarkDocId = bookmarkDoc['bookmarkId'];

          await FirebaseFirestore.instance
              .collection(Bookmarks.collectionName)
              .doc(bookmarkDocId)
              .delete();
        }
      }
      await updateJobApplicationsFailedStatus(job, user, jobApplication);
    } catch (e) {
      await showDialogPrompt(false, "assets/images/unsuccessful.png",
          LanguageConverterHelper.getAcceptFailedTextLang(widget.language));
    }
  }

  Future<void> updateJobApplicationsFailedStatus(
      Jobs job, Users user, JobApplications jobApplication) async {
    try {
      final jobApplicationSnapshots = await FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .where('userId', isNotEqualTo: user.userId)
          .get();

      if (jobApplicationSnapshots.docs.isNotEmpty) {
        final jobApplicationDocs = jobApplicationSnapshots.docs;

        for (QueryDocumentSnapshot jobApplicationDoc in jobApplicationDocs) {
          String jobApplicationDocId = jobApplicationDoc['jobApplicationId'];

          await FirebaseFirestore.instance
              .collection(JobApplications.collectionName)
              .doc(jobApplicationDocId)
              .update({'applicationStatus': "Failed"});
        }
      }

      await updateJobApplicationSuccessStatus(job, user, jobApplication);
    } catch (e) {
      await showDialogPrompt(false, "assets/images/unsuccessful.png",
          LanguageConverterHelper.getAcceptFailedTextLang(widget.language));
    }
  }

  Future<void> updateJobApplicationSuccessStatus(
      Jobs job, Users user, JobApplications jobApplication) async {
    try {
      final jobApplicationSnapshot = await FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .where('userId', isEqualTo: user.userId)
          .limit(1)
          .get();

      if (jobApplicationSnapshot.docs.isNotEmpty) {
        final jobApplicationDocId = jobApplicationSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection(JobApplications.collectionName)
            .doc(jobApplicationDocId)
            .update({'applicationStatus': "Success"});

        await updateJobApplicantIsFound(job, jobApplication);
      }
    } catch (e) {
      await showDialogPrompt(false, "assets/images/unsuccessful.png",
          LanguageConverterHelper.getAcceptFailedTextLang(widget.language));
    }
  }

  Future<void> updateJobApplicantIsFound(
      Jobs job, JobApplications jobApplication) async {
    try {
      await FirebaseFirestore.instance
          .collection(Jobs.collectionName)
          .doc(job.jobId)
          .update({'applicantIsFound': true});

      await showDialogPrompt(true, "assets/images/successful.png",
          LanguageConverterHelper.getAcceptSuccessTextLang(widget.language),
          jobApplication: jobApplication);
    } catch (e) {
      await showDialogPrompt(false, "assets/images/unsuccessful.png",
          LanguageConverterHelper.getAcceptFailedTextLang(widget.language));
    }
  }

  // update job application status to failed
  Future<void> rejectApplicant(Jobs job, Users user) async {
    try {
      final jobApplicationSnapshot = await FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .where('userId', isEqualTo: user.userId)
          .limit(1)
          .get();

      if (jobApplicationSnapshot.docs.isNotEmpty) {
        final jobApplicationDocId = jobApplicationSnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection(JobApplications.collectionName)
            .doc(jobApplicationDocId)
            .update({'applicationStatus': "Failed"});

        await showDialogPrompt(
          false,
          "assets/images/successful.png",
          LanguageConverterHelper.getRejectSuccessTextLang(widget.language),
        );
      }
    } catch (e) {
      await showDialogPrompt(
        false,
        "assets/images/unsuccessful.png",
        LanguageConverterHelper.getRejectFailedTextLang(widget.language),
      );
    }
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
