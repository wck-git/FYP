import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/recruiter/recruiter_edit_profile.dart';
import 'package:ckfyp02/view/recruiter/recruiter_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/languageConverter.dart';
import '../../helper/languagePreferences.dart';
import '../../model/language.dart';
import '../../model/recruiters.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class RecruiterProfileView extends StatefulWidget {
  const RecruiterProfileView({super.key});

  @override
  State<RecruiterProfileView> createState() => _RecruiterProfileViewState();
}

class _RecruiterProfileViewState extends State<RecruiterProfileView> {
  int currentIndex = 3;
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
              "assets/images/recruiter/profile.png",
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
                  audioPath = "audio/en/profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                }
              }

              break;
            case 3:
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
  Recruiters recruiterDetails = Recruiters(
    recruiterEmail: '',
    mobileNum: '',
    name: '',
    gender: '',
    businessName: '',
    firstLineAddress: '',
    states: '',
    image: '',
  );
  ScrollController scrollbarController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // fetch from firestore
        stream: FirebaseFirestore.instance
            .collection(Recruiters.collectionName)
            .doc(recruiter.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            return const Text('Error fetching details');
          }

          // waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // fetch recruiter details
          if (snapshot.hasData && snapshot.data!.exists) {
            var recruiterData = snapshot.data!.data();

            recruiterDetails = Recruiters.fromJson(recruiterData!);
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
                            getProfileImage(recruiterDetails.gender),
                        width: Images.recrNarrowProfileIconWidth,
                        height: Images.recrNarrowProfileIconHeight,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // name
                    Text(
                      recruiterDetails.name,
                      style: const TextStyle(
                          fontFamily: Fonts.primaryFont,
                          fontSize: Fonts.profileRecrTitleFontSize,
                          color: Colours.primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // profile details
              Expanded(
                child: Container(
                  width: double.infinity,
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
                          // email
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/recruiter/mail.png",
                                width: Images.recrNarrowSmallIconWidth,
                                height: Images.recrNarrowSmallIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  recruiterDetails.recruiterEmail,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // mobile num'
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/recruiter/phone_number.png",
                                width: Images.recrNarrowSmallIconWidth,
                                height: Images.recrNarrowSmallIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  recruiterDetails.mobileNum,
                                  style: const TextStyle(
                                    fontFamily: Fonts.primaryFont,
                                    fontSize: Fonts.primaryRecrFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          // business name
                          Row(
                            children: [
                              Image.asset(
                                "assets/images/recruiter/business.png",
                                width: Images.recrNarrowSmallIconWidth,
                                height: Images.recrNarrowSmallIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  recruiterDetails.businessName,
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
                            children: [
                              Image.asset(
                                "assets/images/recruiter/address_first_line.png",
                                width: Images.recrNarrowSmallIconWidth,
                                height: Images.recrNarrowSmallIconHeight,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  recruiterDetails.firstLineAddress,
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
                            children: [
                              getStatesImage(recruiterDetails.states),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  recruiterDetails.states,
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
              const SizedBox(height: 20.0),
              // edit details button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RecrNarrowButton(
                      buttonText:
                          LanguageConverterHelper.getEditProfileTextLang(
                              widget.language),
                      color: Colours.primaryColor,
                      iconPath: "assets/images/recruiter/sign_up.png",
                      iconSecondPath: "assets/images/recruiter/profile.png",
                      isSmallButton: false,
                      onPressed: () {
                        widget.audioPlayer.dispose();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecruiterEditProfileView(
                                      recruiterDetails: recruiterDetails,
                                    ))).then((value) => widget.getLanguage());
                      },
                    ),
                  ],
                ),
              ),
              // log out button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RecrNarrowButton(
                      buttonText: LanguageConverterHelper.getLogoutTextLang(
                          widget.language),
                      color: Colours.feedbackIncorrectColor,
                      iconPath: "assets/images/recruiter/exit.png",
                      iconSecondPath: "assets/images/recruiter/walk.png",
                      isSmallButton: false,
                      onPressed: () async {
                        widget.audioPlayer.dispose();
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove('isLoggedIn');
                        prefs.remove('accountRole');

                        await FirebaseAuth.instance.signOut().then((value) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/mainView',
                            (route) => false,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget getProfileImage(String gender) {
    String iconPath = "assets/images/recruiter/boy.png";

    if (gender == "Girl") {
      iconPath = "assets/images/recruiter/girl.png";
    }

    return Container(
      child: Image.asset(
        iconPath,
        width: Images.recrNarrowProfileIconWidth,
        height: Images.recrNarrowProfileIconHeight,
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
      width: Images.recrNarrowSmallIconWidth,
      height: Images.recrNarrowSmallIconHeight,
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
