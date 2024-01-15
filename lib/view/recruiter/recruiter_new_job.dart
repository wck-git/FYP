import 'package:audioplayers/audioplayers.dart';
import 'package:ckfyp02/helper/timeZoneConverter.dart';
import 'package:ckfyp02/view/layout/loading.dart';
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
import '../../model/jobs.dart';
import '../../model/language.dart';
import '../../model/recruiters.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/input_field.dart';
import '../layout/language_drop_down_menu.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart'; // for date formatter

class RecruiterNewJobView extends StatefulWidget {
  const RecruiterNewJobView({super.key});

  @override
  State<RecruiterNewJobView> createState() => _RecruiterNewJobViewState();
}

class _RecruiterNewJobViewState extends State<RecruiterNewJobView> {
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
              "assets/images/recruiter/hiring.png",
              width: Images.recrNarrowIconWidth,
              height: Images.recrNarrowIconHeight,
            ),
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
                  audioPath = "audio/en/new_job.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/new_job.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/new_job.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/new_job.mp3";
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  DateFormat timeFormatter = DateFormat("hh:mm a");
  DateFormat dateTimeFormatter = DateFormat("y-MM-dd hh:mm a");
  String? selectedJobNameValue;
  Map<String, Image> jobNameMap = {
    'Waiter': Image.asset(
      "assets/images/recruiter/waiter.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
    'Cashier': Image.asset(
      "assets/images/recruiter/cashier.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
    'Dish Washer': Image.asset(
      "assets/images/recruiter/dish_washer.jpeg",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
    'Promoter': Image.asset(
      "assets/images/recruiter/promoter.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
    'Cleaner': Image.asset(
      "assets/images/recruiter/cleaner.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
  };
  final TextEditingController jobStartTimeController = TextEditingController();
  final TextEditingController jobEndTimeController = TextEditingController();
  final TextEditingController jobPayController = TextEditingController();
  TimeOfDay jobStartTime = TimeOfDay.now();
  TimeOfDay jobEndTime = TimeOfDay.now();
  ScrollController scrollbarController = ScrollController();
  bool loading = false;

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.dispose();
    jobStartTimeController.dispose();
    jobEndTimeController.dispose();
    jobPayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingView()
        : Column(
            children: [
              // new job text row
              Container(
                width: double.infinity,
                child: Container(
                  child: Row(
                    children: [
                      // image
                      Container(
                        child: Image.asset(
                          "assets/images/recruiter/hiring.png",
                          width: Images.recrNarrowIconWidth,
                          height: Images.recrNarrowIconHeight,
                        ),
                      ),
                      const SizedBox(width: 10.0),
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
                            LanguageConverterHelper.getNewJobTitleTextLang(
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
              // new job input
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 10.0,
                  controller: scrollbarController,
                  child: ListView(
                    controller: scrollbarController,
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // job name input
                            RecrNarrowDropDownInput(
                              inputHintTitle:
                                  LanguageConverterHelper.getJobTextLang(
                                      widget.language),
                              iconPath: "assets/images/recruiter/job.png",
                              selectedValue: selectedJobNameValue,
                              map: jobNameMap,
                              onChanged: (value) {
                                setState(() {
                                  selectedJobNameValue = value.toString();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return LanguageConverterHelper.getJobTextLang(
                                      widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // job start time input
                            RecrPickerInput(
                              inputHintTitle:
                                  LanguageConverterHelper.getStartTimeTextLang(
                                      widget.language),
                              iconPath: "assets/images/recruiter/job.png",
                              hasTwoIcons: true,
                              secondIconPath:
                                  "assets/images/recruiter/time.png",
                              controller: jobStartTimeController,
                              onTap: () async {
                                TimeOfDay? pickedStartTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay
                                      .now(), // time displays to user in the picker
                                  // initialEntryMode: TimePickerEntryMode.input,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedStartTime != null) {
                                  setState(() {
                                    jobStartTime = pickedStartTime;
                                  });
                                  final localizations =
                                      MaterialLocalizations.of(context);
                                  final formattedTimeOfDay = localizations
                                      .formatTimeOfDay(pickedStartTime);
                                  jobStartTimeController.text =
                                      formattedTimeOfDay.toString();
                                }
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getStartTimeTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // job end time input
                            RecrPickerInput(
                              inputHintTitle:
                                  LanguageConverterHelper.getEndTimeTextLang(
                                      widget.language),
                              iconPath: "assets/images/recruiter/home.png",
                              hasTwoIcons: true,
                              secondIconPath:
                                  "assets/images/recruiter/time.png",
                              controller: jobEndTimeController,
                              onTap: () async {
                                TimeOfDay? pickedEndTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay
                                      .now(), // time displays to user in the picker
                                  // initialEntryMode: TimePickerEntryMode.input,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedEndTime != null) {
                                  setState(() {
                                    jobEndTime = pickedEndTime;
                                  });
                                  final localizations =
                                      MaterialLocalizations.of(context);
                                  final formattedTimeOfDay = localizations
                                      .formatTimeOfDay(pickedEndTime);
                                  jobEndTimeController.text =
                                      formattedTimeOfDay.toString();
                                }
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getEndTimeTextLang(widget.language);
                                } else if (!isValidJobEndTime()) {
                                  return LanguageConverterHelper
                                      .getEndTimeConditionTextLang(
                                          widget.language);
                                }
                                ;
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // job pay input
                            RecrNarrowInput(
                              controller: jobPayController,
                              inputHintText: "50.00",
                              iconPath: "assets/images/recruiter/money.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: true,
                              textInputType: TextInputType.number,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getJobPayTextLang(widget.language);
                                } else if (double.parse(value) < 1 ||
                                    double.parse(value) > 300) {
                                  return LanguageConverterHelper
                                      .getJobPayInvalidTextLang(
                                          widget.language);
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // new job button
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(Recruiters.collectionName)
                      .doc(recruiter.uid)
                      .snapshots(),
                  builder: (context, recruiterSnapshot) {
                    // error
                    if (recruiterSnapshot.hasError) {
                      return const Text('Error fetching details');
                    }

                    // waiting
                    if (recruiterSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (recruiterSnapshot.hasData &&
                        recruiterSnapshot.data!.exists) {
                      final recruiterData = recruiterSnapshot.data!.data();
                      Recruiters recruiter =
                          Recruiters.fromJson(recruiterData!);

                      return Container(
                        margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                        child: RecrNarrowButton(
                          buttonText: "OK",
                          color: Colours.primaryColor,
                          iconPath: "assets/images/recruiter/ok.png",
                          isSmallButton: false,
                          onPressed: () async {
                            // validation
                            if (formKey.currentState!.validate()) {
                              final job = Jobs(
                                recruiterId: recruiter.recruiterId,
                                jobName: selectedJobNameValue.toString(),
                                jobStartTime: TimeZoneConverterHelper
                                    .subtractOffset(dateTimeFormatter.parse(
                                        '${dateFormatter.format(DateTime.now()).toString()} ${jobStartTimeController.text}')),
                                jobEndTime: TimeZoneConverterHelper
                                    .subtractOffset(dateTimeFormatter.parse(
                                        '${dateFormatter.format(DateTime.now()).toString()} ${jobEndTimeController.text}')),
                                jobPay: double.parse(jobPayController.text),
                                businessName: recruiter.businessName,
                                firstLineAddress: recruiter.firstLineAddress,
                                states: recruiter.states,
                                jobPostedDateTime: DateTime.now().toUtc(),
                                applicantIsFound: false,
                              );

                              final connectionCheckerHelper =
                                  ConnectionCheckerHelper();
                              bool hasConnection = await connectionCheckerHelper
                                  .checkConnection();

                              if (hasConnection) {
                                setState(() {
                                  loading = true;
                                });
                                await addJob(job);
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
                            }
                          },
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
            ],
          );
  }

  Future<void> showDialogPrompt(
      bool isSuccess, String iconPath, String dialogMessage) async {
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
                    widget.audioPlayer.dispose();
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
    } catch (e) {
      print(e);
    }
  }

  // valid end time when end time is later than start time (DAY)
  bool isValidJobEndTime() {
    double doubleJobStartTime =
        jobStartTime.hour.toDouble() + (jobStartTime.minute.toDouble() / 60);
    double doubleJobEndTime =
        jobEndTime.hour.toDouble() + (jobEndTime.minute.toDouble() / 60);

    double timeDiff = doubleJobEndTime - doubleJobStartTime;

    if (timeDiff > 0) {
      return true;
    }
    return false;
  }

  Future addJob(Jobs job) async {
    try {
      final jobDoc =
          FirebaseFirestore.instance.collection(Jobs.collectionName).doc();
      job.jobId = jobDoc.id;
      final json = job.toJson();
      await jobDoc.set(json);

      await showDialogPrompt(true, "assets/images/successful.png",
          LanguageConverterHelper.getAddJobSuccessTextLang(widget.language));
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
