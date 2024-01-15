import 'package:audioplayers/audioplayers.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/recruiter/recruiter_employee.dart';
import 'package:ckfyp02/view/recruiter/recruiter_applicants_list.dart';
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
import '../../model/bookmarks.dart';
import '../../model/job_applications.dart';
import '../../model/jobs.dart';
import '../../model/language.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import 'package:intl/intl.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class RecruiterJobDetailsView extends StatefulWidget {
  Jobs job;

  RecruiterJobDetailsView({
    required this.job,
  });

  @override
  State<RecruiterJobDetailsView> createState() =>
      _RecruiterJobDetailsViewState();
}

class _RecruiterJobDetailsViewState extends State<RecruiterJobDetailsView> {
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
                  audioPath = "audio/en/job_details.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/job_details.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/job_details.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/job_details.mp3";
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
  final User user = FirebaseAuth.instance.currentUser!;
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("h:mm a");
  ScrollController scrollbarController = ScrollController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingView()
        : Column(
            children: [
              // image and name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: getJobStatusIcon(widget.job),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // image
                          getJobImage(widget.job.jobName),
                          // name
                          Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              LanguageConverterHelper.getJobNameLang(
                                  widget.language, widget.job.jobName),
                              style: const TextStyle(
                                  fontFamily: Fonts.primaryFont,
                                  fontSize: Fonts.profileRecrTitleFontSize,
                                  color: Colours.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // job details
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 15.0,
                        spreadRadius: 0.1,
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 10.0,
                    controller: scrollbarController,
                    child: SingleChildScrollView(
                      controller: scrollbarController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // icon
                              Image.asset("assets/images/recruiter/time.png",
                                  width: Images.recrNarrowInputIconWidth,
                                  height: Images.recrNarrowInputIconHeight),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                  ("${timeFormatter.format(widget.job.jobStartTime)} - ${timeFormatter.format(widget.job.jobEndTime)}"),
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // pay
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // icon
                              Image.asset("assets/images/recruiter/money.png",
                                  width: Images.recrNarrowInputIconWidth,
                                  height: Images.recrNarrowInputIconHeight),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                  ('RM ${widget.job.jobPay.toStringAsFixed(2)}'),
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // business
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // icon
                              Image.asset(
                                  "assets/images/recruiter/business.png",
                                  width: Images.recrNarrowInputIconWidth,
                                  height: Images.recrNarrowInputIconHeight),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                  widget.job.businessName,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // business address
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // icon
                              Image.asset(
                                  "assets/images/recruiter/address_first_line.png",
                                  width: Images.recrNarrowInputIconWidth,
                                  height: Images.recrNarrowInputIconHeight),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                  widget.job.firstLineAddress,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // states
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // icon
                              getStatesImage(widget.job.states),
                              const SizedBox(width: 5.0),
                              Expanded(
                                child: Text(
                                  widget.job.states,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // job applicant button
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Jobs.collectionName)
                      .doc(widget.job.jobId)
                      .snapshots(),
                  builder: ((context, jobsSnapshot) {
                    // error
                    if (jobsSnapshot.hasError) {
                      return const Text('Error fetching details');
                    }

                    // waiting
                    if (jobsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (jobsSnapshot.hasData && jobsSnapshot.data!.exists) {
                      final jobDoc = jobsSnapshot.data!;
                      final jobData = jobDoc.data()!;
                      Jobs job = Jobs.fromJson(jobData);

                      // applicant is found
                      if (job.applicantIsFound) {
                        // retrieve job application
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(JobApplications.collectionName)
                                .where('jobId', isEqualTo: job.jobId)
                                .where('applicationStatus',
                                    isEqualTo: "Success")
                                .limit(1)
                                .snapshots(),
                            builder: (context, jobApplicationsSnapshot) {
                              // error
                              if (jobApplicationsSnapshot.hasError) {
                                return const Text('Error fetching details');
                              }

                              // applicant is found, job application record is success
                              if (jobApplicationsSnapshot.hasData &&
                                  jobApplicationsSnapshot
                                      .data!.docs.isNotEmpty) {
                                final jobApplicationsDoc =
                                    jobApplicationsSnapshot.data!.docs.first;
                                final jobApplicationData =
                                    jobApplicationsDoc.data();
                                final jobApplication = JobApplications.fromJson(
                                    jobApplicationData);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15.0),
                                  child: RecrNarrowButton(
                                    buttonText: LanguageConverterHelper
                                        .getEmployeeTextLang(widget.language),
                                    iconPath: "assets/images/recruiter/boy.png",
                                    color: Colours.primaryColor,
                                    isSmallButton: false,
                                    // applicant button -> directly navigate to employee page
                                    onPressed: () async {
                                      widget.audioPlayer.dispose();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecruiterEmployeeView(
                                                    jobApplication:
                                                        jobApplication,
                                                  ))).then(
                                          (value) => widget.getLanguage());
                                    },
                                  ),
                                );
                              }
                              // applicant is found but job application record no success
                              else {
                                return const SizedBox();
                              }
                            });
                      }
                      // applicant is not found
                      else {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          child: RecrNarrowButton(
                            buttonText:
                                LanguageConverterHelper.getApplicantTextLang(
                                    widget.language),
                            iconPath: "assets/images/recruiter/boy.png",
                            color: Colours.primaryColor,
                            isSmallButton: false,
                            // applicant button -> navigate to job applicants list view page
                            onPressed: () {
                              widget.audioPlayer.dispose();
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecruiterApplicantsListView(
                                                job: job,
                                              )))
                                  .then((value) => widget.getLanguage());
                            },
                          ),
                        );
                      }
                    }
                    // job is deleted
                    else {
                      return const SizedBox();
                    }
                  })),
              // delete button
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
                  if (jobsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (jobsSnapshot.hasData && jobsSnapshot.data!.exists) {
                    final jobDoc = jobsSnapshot.data!;
                    final jobData = jobDoc.data()!;
                    Jobs job = Jobs.fromJson(jobData);

                    if (job.applicantIsFound) {
                      return const SizedBox();
                    }

                    // delete button
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: RecrNarrowButton(
                        buttonText: LanguageConverterHelper.getDeleteTextLang(
                            widget.language),
                        color: Colours.feedbackIncorrectColor,
                        iconPath: "assets/images/recruiter/delete.png",
                        isSmallButton: false,
                        onPressed: () async {
                          widget.audioPlayer.dispose();
                          final connectionCheckerHelper =
                              ConnectionCheckerHelper();
                          bool hasConnection =
                              await connectionCheckerHelper.checkConnection();

                          if (hasConnection) {
                            setState(() {
                              loading = true;
                            });
                            await deleteJob(job);
                          } else {
                            await showDialogPrompt(
                              false,
                              "assets/images/unsuccessful.png",
                              LanguageConverterHelper.getNoWifiTextLang(
                                  widget.language),
                            );
                          }

                          setState(() {
                            loading = false;
                          });
                        },
                      ),
                    );
                  }
                  // no job data anymore
                  else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          );
  }

  Widget getJobStatusIcon(Jobs job) {
    String iconPath;

    if (job.applicantIsFound) {
      iconPath = "assets/images/successful.png";
    } else {
      return const SizedBox();
    }
    return Container(
      child: Image.asset(
        iconPath,
        width: Images.recrNarrowCardIconWidth,
        height: Images.recrNarrowCardIconHeight,
      ),
    );
  }

  Future<void> showDialogPrompt(
      bool isSuccess, String iconPath, String dialogMessage) async {
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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
        width: Images.recrNarrowProfileIconWidth,
        height: Images.recrNarrowProfileIconWidth,
      ),
    );
  }

  Widget getStatesImage(String states) {
    String iconPath;

    switch (states) {
      case 'Johor':
        iconPath = "assets/images/states/johor.png";
        break;
      case 'Kedah':
        iconPath = "assets/images/states/kedah.png";
        break;
      case 'Kelantan':
        iconPath = "assets/images/states/kelantan.png";
        break;
      case 'Perak':
        iconPath = "assets/images/states/perak.png";
        break;
      case 'Selangor':
        iconPath = "assets/images/states/selangor.png";
        break;
      case 'Malacca':
        iconPath = "assets/images/states/malacca.png";
        break;
      case 'Negeri Sembilan':
        iconPath = "assets/images/states/negeri_sembilan.png";
        break;
      case 'Pahang':
        iconPath = "assets/images/states/pahang.png";
        break;
      case 'Perlis':
        iconPath = "assets/images/states/perlis.png";
        break;
      case 'Penang':
        iconPath = "assets/images/states/penang.png";
        break;
      case 'Sabah':
        iconPath = "assets/images/states/sabah.png";
        break;
      case 'Sarawak':
        iconPath = "assets/images/states/sarawak.png";
        break;
      case 'Terengganu':
        iconPath = "assets/images/states/terengganu.png";
        break;
      default:
        iconPath = "assets/images/states/selangor.png";
        break;
    }

    return Image.asset(
      iconPath,
      width: Images.recrNarrowInputIconWidth,
      height: Images.recrNarrowInputIconHeight,
    );
  }

  Future<void> deleteJob(Jobs job) async {
    try {
      await FirebaseFirestore.instance
          .collection(Jobs.collectionName)
          .doc(job.jobId)
          .delete();

      await deleteUserBookmarks(job);
    } catch (e) {
      await showDialogPrompt(
          false, "assets/images/unsuccessful.png", e.toString());
    }
  }

  Future<void> deleteUserBookmarks(Jobs job) async {
    try {
      final bookmarkDocsSnapshot = await FirebaseFirestore.instance
          .collection(Bookmarks.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .get();

      if (bookmarkDocsSnapshot.docs.isNotEmpty) {
        final bookmarkDocs = bookmarkDocsSnapshot.docs;

        for (QueryDocumentSnapshot bookmarkDoc in bookmarkDocs) {
          // get the doc id
          String bookmarkDocId = bookmarkDoc['bookmarkId'];

          // delete
          await FirebaseFirestore.instance
              .collection(Bookmarks.collectionName)
              .doc(bookmarkDocId)
              .delete();
        }
      }

      await deleteUserJobApplication(job);
    } catch (e) {
      await showDialogPrompt(
          false, "assets/images/unsuccessful.png", e.toString());
    }
  }

  Future<void> deleteUserJobApplication(Jobs job) async {
    try {
      final jobApplicationDocsSnapshot = await FirebaseFirestore.instance
          .collection(JobApplications.collectionName)
          .where('jobId', isEqualTo: job.jobId)
          .get();

      if (jobApplicationDocsSnapshot.docs.isNotEmpty) {
        final jobApplicationDocs = jobApplicationDocsSnapshot.docs;

        for (QueryDocumentSnapshot jobApplicationDoc in jobApplicationDocs) {
          // get the doc id
          String jobApplicationDocId = jobApplicationDoc['jobApplicationId'];

          // delete
          await FirebaseFirestore.instance
              .collection(JobApplications.collectionName)
              .doc(jobApplicationDocId)
              .delete();
        }
      }
      await showDialogPrompt(true, "assets/images/successful.png",
          LanguageConverterHelper.getDeleteSuccessTextLang(widget.language));
    } catch (e) {
      await showDialogPrompt(
          false, "assets/images/unsuccessful.png", e.toString());
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
