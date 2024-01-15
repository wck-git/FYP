import 'package:audioplayers/audioplayers.dart';
import 'package:ckfyp02/helper/languageConverter.dart';
import 'package:ckfyp02/view/layout/bottom_nav_bar.dart';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/layout/language_drop_down_menu.dart';
import 'package:ckfyp02/view/layout/responsive_layout.dart';
import 'package:ckfyp02/view/recruiter/recruiter_home.dart';
import 'package:ckfyp02/view/recruiter/recruiter_login.dart';
import 'package:ckfyp02/view/user/user_login.dart';
import 'package:ckfyp02/view/user/user_main.dart';
import 'package:ckfyp02/view/util/colours.dart';
import 'package:ckfyp02/view/util/fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helper/languagePreferences.dart';
import 'model/language.dart';
import 'model/recruiters.dart';
import 'model/users.dart';
import 'view/util/images.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set to potrait up only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colours.backgroundColor,
        fontFamily: 'Roboto',
      ),
      home: const MainView(),
      routes: {
        '/mainView': (context) => const MainView(),
        '/recruiterHomeView': (context) => const RecruiterHomeView(),
        '/userMainView': (context) => UserMainView(
              index: 0,
            ),
        '/recruiterLoginView': (context) => const RecruiterLoginView(),
        '/userLoginView': (context) => const UserLoginView(),
      },
    ),
  );
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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
    return FutureBuilder(
      future: checkUserType(),
      builder: (context, snapshot) {
        // navigate user login page
        if (snapshot.data == Users.collectionName) {
          return const UserLoginView();
        }
        // navigate recruiter login page
        else if (snapshot.data == Recruiters.collectionName) {
          return const RecruiterLoginView();
        }
        // display main page
        else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colours.primaryColor,
              title: const Text("JOBEE"),
              centerTitle: true,
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
              isAtMainPage: false,
              language: language,
              onTap: (int index) async {
                switch (index) {
                  case 0:
                    audioPlayer.dispose();
                    SystemNavigator.pop();
                    break;
                  case 1:
                    double deviceVolume =
                        await PerfectVolumeControl.getVolume();

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    LanguageConverterHelper
                                        .getIncreaseAudioTextLang(language),
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
                        audioPath = "audio/en/main.mp3";
                        await audioPlayer.play(AssetSource(audioPath));
                      } else if (language == Language.chinese) {
                        audioPath = "audio/ch/main.mp3";
                        audioPlayer.play(AssetSource(audioPath));
                      } else if (language == Language.bahasaMelayu) {
                        audioPath = "audio/bm/main.mp3";
                        audioPlayer.play(AssetSource(audioPath));
                      } else if (language == Language.tamil) {
                        audioPath = "audio/tm/main.mp3";
                        audioPlayer.play(AssetSource(audioPath));
                      }
                    }

                    break;
                  default:
                    break;
                }
              },
            ),
          );
        }
      },
    );
  }

  Future<void> getLanguage() async {
    String selectedLang = await languagePreferencesHelper.getSelectedLanguage();

    setState(() {
      language = selectedLang;
    });
  }

  Future<String> checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountRole = prefs.getString('accountRole');

    if (accountRole == null) {
      return "";
    } else {
      return accountRole;
    }
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: Images.narrowLogoWidth,
                    height: Images.narrowLogoHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GeneralButton(
                  iconPath: "assets/images/recruiter/profile.png",
                  buttonText: LanguageConverterHelper.getHirePeopleTextLang(
                      widget.language),
                  color: Colours.primaryColor,
                  onPressed: () {
                    widget.audioPlayer.dispose();
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RecruiterLoginView()))
                        .then((value) => widget.getLanguage());
                  },
                ),
                const SizedBox(height: 30.0),
                GeneralButton(
                  iconPath: "assets/images/recruiter/boy.png",
                  buttonText: LanguageConverterHelper.getFindJobTextLang(
                      widget.language),
                  color: Colours.primaryColor,
                  onPressed: () {
                    widget.audioPlayer.dispose();
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserLoginView()))
                        .then((value) => widget.getLanguage());
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
