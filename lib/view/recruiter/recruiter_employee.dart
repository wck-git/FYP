import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/helper/languageConverter.dart';
import 'package:ckfyp02/model/job_applications.dart';
import 'package:ckfyp02/view/recruiter/recruiter_home.dart';
import 'package:ckfyp02/view/recruiter/recruiter_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../../helper/languagePreferences.dart';
import '../../model/language.dart';
import '../../model/users.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RecruiterEmployeeView extends StatefulWidget {
  JobApplications jobApplication;

  RecruiterEmployeeView({
    required this.jobApplication,
  });

  @override
  State<RecruiterEmployeeView> createState() => _RecruiterEmployeeViewState();
}

class _RecruiterEmployeeViewState extends State<RecruiterEmployeeView> {
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
            jobApplication: widget.jobApplication,
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
                  audioPath = "audio/en/employee.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/employee.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/employee.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/employee.mp3";
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
  JobApplications jobApplication;
  final AudioPlayer audioPlayer;
  final String language;
  final VoidCallback getLanguage;

  NarrowLayout({
    required this.jobApplication,
    required this.audioPlayer,
    required this.language,
    required this.getLanguage,
  });

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User recruiter = FirebaseAuth.instance.currentUser!;
  Users userDetails = Users(
    userEmail: '',
    mobileNum: '',
    name: '',
    gender: '',
    birthDate: DateTime.now().toUtc(),
    image: '',
  );
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  ScrollController scrollbarController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Users.collectionName)
            .doc(widget.jobApplication.userId)
            .snapshots(),
        builder: (context, usersSnapshot) {
          // error
          if (usersSnapshot.hasError) {
            return const Text('Error fetching details');
          }

          // waiting
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (usersSnapshot.hasData && usersSnapshot.data!.exists) {
            final userDetailsData = usersSnapshot.data!.data();
            userDetails = Users.fromJson(userDetailsData!);
          }

          // UI
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      child: Container(
                        child: Image.asset(
                          "assets/images/successful.png",
                          width: Images.recrNarrowCardIconWidth,
                          height: Images.recrNarrowCardIconHeight,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // image
                          Center(
                            child: CachedNetworkImage(
                              imageUrl: userDetails.image,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  getProfileGenderImage(userDetails.gender),
                              width: Images.recrNarrowProfileIconWidth,
                              height: Images.recrNarrowProfileIconHeight,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          // name
                          Text(
                            userDetails.name,
                            style: const TextStyle(
                                fontFamily: Fonts.primaryFont,
                                fontSize: Fonts.profileRecrTitleFontSize,
                                color: Colours.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // profile details
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 15.0),
                  padding: const EdgeInsets.all(30.0),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // mobile num
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/recruiter/phone_number.png",
                                width: Images.recrNarrowIconWidth,
                                height: Images.recrNarrowIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final Uri call = Uri(
                                        scheme: "tel",
                                        path: userDetails.mobileNum);

                                    if (await canLaunchUrl(call)) {
                                      launchUrl(call);
                                    }
                                  },
                                  child: Text(
                                    userDetails.mobileNum,
                                    style: const TextStyle(
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
                          const SizedBox(height: 20.0),
                          // gender
                          Row(
                            children: [
                              getProfileGenderImage(userDetails.gender),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  LanguageConverterHelper.getGenderLang(
                                      widget.language, userDetails.gender),
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // age
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/recruiter/age.png",
                                width: Images.recrNarrowIconWidth,
                                height: Images.recrNarrowIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  ('${(DateTime.now().year - userDetails.birthDate.year).toStringAsFixed(0)} ${LanguageConverterHelper.getAgeTextLang(widget.language)}'),
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
            ],
          );
        });
  }

  Widget getProfileGenderImage(gender) {
    String iconPath = "assets/images/recruiter/boy.png";

    if (gender == "Girl") {
      iconPath = "assets/images/recruiter/girl.png";
    }

    return Container(
      child: Image.asset(
        iconPath,
        width: Images.recrNarrowIconWidth,
        height: Images.recrNarrowIconHeight,
      ),
    );
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
