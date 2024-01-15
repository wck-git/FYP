import 'package:ckfyp02/view/recruiter/recruiter_job_details.dart';
import 'package:ckfyp02/view/recruiter/recruiter_new_job.dart';
import 'package:ckfyp02/view/recruiter/recruiter_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../../helper/languageConverter.dart';
import '../../helper/languagePreferences.dart';
import '../../model/jobs.dart';
import '../../model/language.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class RecruiterHomeView extends StatefulWidget {
  const RecruiterHomeView({super.key});

  @override
  State<RecruiterHomeView> createState() => _RecruiterHomeViewState();
}

class _RecruiterHomeViewState extends State<RecruiterHomeView> {
  int currentIndex = 0;
  final audioPlayer = AudioPlayer();
  String audioPath = "";
  LanguagePreferencesHelper languagePreferencesHelper =
      LanguagePreferencesHelper();
  String language = "";
  String langCode = "";

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
              "assets/images/recruiter/home.png",
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
                  audioPath = "audio/en/home.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/home.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/home.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/home.mp3";
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
  final AudioPlayer audioPlayer;
  final String language;
  final VoidCallback getLanguage;

  NarrowLayout({
    required this.audioPlayer,
    required this.language,
    required this.getLanguage,
  });

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User recruiter = FirebaseAuth.instance.currentUser!;
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("h:mm a");
  DateFormat dateTimeFormatter = DateFormat("y-MM-dd hh:mm a");
  ScrollController scrollbarController = ScrollController();
  LanguagePreferencesHelper languagePreferencesHelper =
      LanguagePreferencesHelper();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    "assets/images/recruiter/profile.png",
                    width: Images.recrNarrowIconWidth,
                    height: Images.recrNarrowIconHeight,
                  ),
                ),
                const SizedBox(width: 10.0),
                // image
                Container(
                  child: Image.asset(
                    "assets/images/recruiter/job.png",
                    width: Images.recrNarrowIconWidth,
                    height: Images.recrNarrowIconHeight,
                  ),
                ),
                const SizedBox(width: 10.0),
                // text
                Expanded(
                  child: Container(
                    child: Text(
                      LanguageConverterHelper.getHomeTitleTextLang(
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
        // job list view
        Expanded(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Jobs.collectionName)
                  .where('recruiterId', isEqualTo: recruiter.uid)
                  .orderBy('jobPostedDateTime', descending: true)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot jobsSnapshot) {
                // error
                if (jobsSnapshot.hasError) {
                  return const Text('Error fetching user details');
                }

                // waiting
                if (jobsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // fetch details
                if (jobsSnapshot.hasData && jobsSnapshot.data.docs.isNotEmpty) {
                  final jobDocs = jobsSnapshot.data!.docs;
                  return Scrollbar(
                    thumbVisibility: true,
                    thickness: 10.0,
                    controller: scrollbarController,
                    child: ListView.builder(
                      itemCount: jobDocs.length,
                      controller: scrollbarController,
                      itemBuilder: (context, index) {
                        // retrieve job information by iterating the jobDocs list
                        final jobDoc = jobDocs[index];
                        final jobData = jobDoc.data();
                        Jobs job = Jobs.fromJson(jobData);

                        // UI
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.audioPlayer.dispose();
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RecruiterJobDetailsView(
                                                  job: job,
                                                )))
                                    .then((value) => widget.getLanguage());
                              },
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    // brief job details
                                    Container(
                                      // height: 225.0,
                                      padding: const EdgeInsets.only(
                                          top: 20.0, bottom: 20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(width: 1.5),
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
                                      child: Row(
                                        children: [
                                          // image
                                          Expanded(
                                            flex: 25,
                                            child: Container(
                                              // job image
                                              child: getJobImage(job.jobName),
                                            ),
                                          ),
                                          //details
                                          Expanded(
                                            flex: 55,
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
                                                    LanguageConverterHelper
                                                        .getJobNameLang(
                                                            widget.language,
                                                            job.jobName),
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            Fonts.primaryFont,
                                                        fontSize: Fonts
                                                            .cardRecrTitleFontSize,
                                                        color: Colours
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  // job time
                                                  Text(
                                                    ("${timeFormatter.format(job.jobStartTime)} - ${timeFormatter.format(job.jobEndTime)}"),
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          Fonts.primaryFont,
                                                      fontSize: Fonts
                                                          .primaryRecrFontSize,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  // job pay
                                                  Text(
                                                    ('RM ${job.jobPay.toStringAsFixed(2)} (${(job.jobEndTime.difference(job.jobStartTime).inMinutes / 60).toStringAsFixed(1)} hours)'),
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          Fonts.primaryFont,
                                                      fontSize: Fonts
                                                          .primaryRecrFontSize,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20.0),
                                                  // job posted date time
                                                  Text(
                                                    dateFormatter.format(
                                                        job.jobPostedDateTime),
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          Fonts.primaryFont,
                                                      fontSize: Fonts
                                                          .primaryRecrFontSize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // status icon
                                          Expanded(
                                              flex: 25,
                                              child: getCardIcon(job)),
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
                      },
                    ),
                  );
                }
                // 0 Jobs Posted
                return Text(
                  LanguageConverterHelper.getZeroJobsPostedTextLang(
                      widget.language),
                );
              }),
        ),
        // new job button
        Container(
          margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
          child: RecrNarrowButton(
              buttonText:
                  LanguageConverterHelper.getNewJobTextLang(widget.language),
              iconPath: "assets/images/recruiter/hiring.png",
              iconSecondPath: "assets/images/recruiter/job.png",
              isSmallButton: false,
              color: Colours.primaryColor,
              onPressed: () async {
                widget.audioPlayer.dispose();
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecruiterNewJobView()))
                    .then((value) => widget.getLanguage());
              }),
        ),
      ],
    );
  }

  Widget getCardIcon(Jobs job) {
    String iconPath;

    if (job.applicantIsFound) {
      iconPath = "assets/images/successful.png";
    } else {
      iconPath = "assets/images/recruiter/arrow_next.png";
    }

    return Container(
      child: Image.asset(
        iconPath,
        width: Images.recrNarrowCardIconWidth,
        height: Images.recrNarrowCardIconHeight,
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
        width: Images.recrNarrowCardIconWidth,
        height: Images.recrNarrowCardIconHeight,
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
