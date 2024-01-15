import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:ckfyp02/helper/languageConverter.dart';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/recruiter/recruiter_sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/languagePreferences.dart';
import '../../model/language.dart';
import '../../model/recruiters.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/input_field.dart';
import '../layout/language_drop_down_menu.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import '../layout/responsive_layout.dart';

class RecruiterLoginView extends StatefulWidget {
  const RecruiterLoginView({super.key});

  @override
  State<RecruiterLoginView> createState() => _RecruiterLoginViewState();
}

class _RecruiterLoginViewState extends State<RecruiterLoginView> {
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
      future: isRecruiterLoggedIn(),
      builder: (context, snapshot) {
        // user is logged in
        if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/recruiterHomeView',
              (route) => false,
            );
          });
        }

        // recruiter is not logged in
        return Scaffold(
          resizeToAvoidBottomInset: false, // disable the bottom button pops up
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/recruiter/walk.png",
                  width: Images.recrNarrowIconWidth,
                  height: Images.recrNarrowIconHeight,
                ),
                Image.asset(
                  "assets/images/recruiter/enter.png",
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
            isAtMainPage: false,
             language: language,
            onTap: (int index) async {
              switch (index) {
                case 0:
                  audioPlayer.dispose();
                  Navigator.of(context).pop();
                  break;
                case 1:
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
                      audioPath = "audio/en/login.mp3";
                      audioPlayer.play(AssetSource(audioPath));
                    } else if (language == Language.chinese) {
                      audioPath = "audio/ch/login.mp3";
                      audioPlayer.play(AssetSource(audioPath));
                    } else if (language == Language.bahasaMelayu) {
                      audioPath = "audio/bm/login.mp3";
                      audioPlayer.play(AssetSource(audioPath));
                    } else if (language == Language.tamil) {
                      audioPath = "audio/tm/login.mp3";
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
      },
    );
  }

  Future<void> getLanguage() async {
    String selectedLang = await languagePreferencesHelper.getSelectedLanguage();

    setState(() {
      language = selectedLang;
    });
  }

  Future<bool> isRecruiterLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == null) {
      return false;
    }
    return true;
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool invalidEmail = false;
  bool invalidPassword = false;
  bool loading = false;

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingView()
        : Column(
            children: [
              // logo and text
              Container(
                width: double.infinity,
                // color: Colors.amber,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // color: Colors.blue,
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: Images.narrowLogoWidth,
                        height: Images.narrowLogoHeight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // input field
              Expanded(
                child: ListView(
                  shrinkWrap: true, // shrink the content to its original size
                  children: [
                    Form(
                      key: formKey,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // email input
                            RecrNarrowInput(
                              controller: emailController,
                              inputHintText: "tan@gmail.com",
                              iconPath: "assets/images/recruiter/mail.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: true,
                              textInputType: TextInputType.emailAddress,
                              errorText: invalidEmail
                                  ? LanguageConverterHelper
                                      .getWrongEmailTextLang(widget.language)
                                  : null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getEmailTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            // password input
                            const SizedBox(height: 20),
                            RecrNarrowInput(
                              controller: passwordController,
                              inputHintText: "*******",
                              iconPath: "assets/images/recruiter/password.png",
                              isObscureText: true,
                              isEnableSuggestions: false,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
                              errorText: invalidPassword
                                  ? LanguageConverterHelper
                                      .getWrongPasswordTextLang(widget.language)
                                  : null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getPasswordTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // login and sign up button
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: Column(
                  children: [
                    Container(
                      child: RecrNarrowButton(
                        buttonText: LanguageConverterHelper.getLoginTextLang(
                            widget.language),
                        iconPath: "assets/images/recruiter/walk.png",
                        iconSecondPath: "assets/images/recruiter/enter.png",
                        isSmallButton: false,
                        color: Colours.primaryColor,
                        onPressed: () async {
                          widget.audioPlayer.dispose();
                          if (formKey.currentState!.validate()) {
                            bool recrExists = await isRecruiterExist();

                            if (recrExists) {
                              setState(() {
                                loading = true;
                              });
                              await login();
                            } else {
                              setState(() {
                                invalidEmail = true;
                              });
                            }
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    // sign up button
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RecrNarrowButton(
                              buttonText:
                                  LanguageConverterHelper.getSignUpTextLang(
                                      widget.language),
                              iconPath: "assets/images/recruiter/sign_up.png",
                              color: Colours.primaryColor,
                              isSmallButton: true,
                              onPressed: () {
                                widget.audioPlayer.dispose();
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RecruiterSignUpView()))
                                    .then((value) => widget.getLanguage());
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  Future login() async {
    try {
      setState(() {
        invalidEmail = false;
        invalidPassword = false;
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('accountRole', Recruiters.collectionName).then((value) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/recruiterHomeView',
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        setState(() {
          invalidEmail = true;
        });
      } else if (e.code == "wrong-password") {
        setState(() {
          invalidPassword = true;
        });
      } else if (e.code == "too-many-requests") {
        await showDialogPrompt(
          false,
          "assets/images/unsuccessful.png",
          LanguageConverterHelper.getTooManyTimesTextLang(widget.language),
        );
      } else if (e.code == "network-request-failed") {
        await showDialogPrompt(
          false,
          "assets/images/unsuccessful.png",
          LanguageConverterHelper.getNoWifiTextLang(widget.language),
        );
      } else {
        await showDialogPrompt(
          false,
          "assets/images/unsuccessful.png",
          e.message!,
        );
      }
    }
  }

  Future<bool> isRecruiterExist() async {
    try {
      setState(() {
        invalidEmail = false;
      });
      var doc = await FirebaseFirestore.instance
          .collection(Recruiters.collectionName)
          .where('recruiterEmail', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (doc.docs.first.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  // Future<bool> isRecruiterExist() async {
  //   try {
  //     setState(() {
  //       invalidEmail = false;
  //     });
  //     var doc = await FirebaseFirestore.instance
  //         .collection(Recruiters.collectionName)
  //         .doc(emailController.text.trim())
  //         .get();

  //     if (doc.exists) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
