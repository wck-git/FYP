import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:ckfyp02/helper/languageConverter.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../../helper/connectionChecker.dart';
import '../../helper/languagePreferences.dart';
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

class RecruiterSignUpView extends StatefulWidget {
  const RecruiterSignUpView({super.key});

  @override
  State<RecruiterSignUpView> createState() => _RecruiterSignUpViewState();
}

class _RecruiterSignUpViewState extends State<RecruiterSignUpView> {
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
      resizeToAvoidBottomInset: true, // enable the bottom button pops up
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/recruiter/sign_up.png",
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
                  audioPath = "audio/en/sign_up.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/sign_up.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/sign_up.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/sign_up.mp3";
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileNumController = TextEditingController();
  final nameController = TextEditingController();
  final businessNameController = TextEditingController();
  final firstLineAddressController = TextEditingController();
  bool invalidEmail = false;
  bool isSignUpSuccessful = false;
  String? selectedGenderValue;
  String? selectedMalaysiaStatesValue;
  Map<String, Image> genderMap = {
    'Boy': Image.asset(
      "assets/images/recruiter/boy.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
    'Girl': Image.asset(
      "assets/images/recruiter/girl.png",
      width: Images.recrNarrowIconWidth,
      height: Images.recrNarrowIconHeight,
    ),
  };
  Map<String, Image> malaysiaStatesMap = {
    'Johor': Image.asset("assets/images/states/johor.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Kedah': Image.asset("assets/images/states/kedah.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Kelantan': Image.asset("assets/images/states/kelantan.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Perak': Image.asset("assets/images/states/perak.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Selangor': Image.asset("assets/images/states/selangor.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Malacca': Image.asset("assets/images/states/malacca.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Negeri Sembilan': Image.asset("assets/images/states/negeri_sembilan.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Pahang': Image.asset("assets/images/states/pahang.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Perlis': Image.asset("assets/images/states/perlis.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Penang': Image.asset("assets/images/states/penang.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Sabah': Image.asset("assets/images/states/sabah.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Sarawak': Image.asset("assets/images/states/sarawak.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
    'Terengganu': Image.asset("assets/images/states/terengganu.png",
        width: Images.recrNarrowIconWidth, height: Images.recrNarrowIconHeight),
  };
  ScrollController scrollbarController = ScrollController();
  String imageUrl = "";
  Uint8List? imageFile;
  bool firstEntry = true;
  bool loading = false;

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.reset();
    emailController.dispose();
    passwordController.dispose();
    mobileNumController.dispose();
    nameController.dispose();
    businessNameController.dispose();
    firstLineAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingView()
        : Column(
            children: [
              // input field
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
                            // email input
                            RecrNarrowInput(
                              controller: emailController,
                              inputHintText: "tan@gmail.com",
                              iconPath: "assets/images/recruiter/mail.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: true,
                              textInputType: TextInputType.emailAddress,
                              errorText: invalidEmail ? "Email taken" : null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getEmailTextLang(widget.language);
                                }
                                bool emailIsValid = RegExp(
                                        r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$',
                                        caseSensitive: false)
                                    .hasMatch(value);
                                if (!emailIsValid) {
                                  return "tan@gmail.com";
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // password input
                            RecrNarrowInput(
                              controller: passwordController,
                              inputHintText: "*******",
                              iconPath: "assets/images/recruiter/password.png",
                              isObscureText: true,
                              isEnableSuggestions: false,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getPasswordTextLang(widget.language);
                                } else if (value.length < 7) {
                                  return LanguageConverterHelper
                                      .getPasswordLengthTextBelowLang(
                                          widget.language);
                                } else if (value.length > 15) {
                                  return LanguageConverterHelper
                                      .getPasswordLengthTextMoreLang(
                                          widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // phone number input
                            RecrNarrowInput(
                              controller: mobileNumController,
                              inputHintText: "0123456789",
                              iconPath:
                                  "assets/images/recruiter/phone_number.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: false,
                              textInputType: TextInputType.phone,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getMobileNumTextLang(widget.language);
                                }
                                bool mobileNumIsValid =
                                    RegExp(r'^\d{10,12}$').hasMatch(value);
                                if (!mobileNumIsValid) {
                                  return "0123456789";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // name input
                            RecrNarrowInput(
                              controller: nameController,
                              inputHintText: "Tan Ah Lock",
                              iconPath: "assets/images/recruiter/name.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getNameTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // gender input
                            RecrNarrowDropDownInput(
                              inputHintTitle:
                                  LanguageConverterHelper.getGenderTextLang(
                                      widget.language),
                              iconPath: "assets/images/recruiter/gender.png",
                              selectedValue: selectedGenderValue,
                              map: genderMap,
                              onChanged: (value) {
                                setState(() {
                                  selectedGenderValue = value.toString();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return LanguageConverterHelper
                                      .getGenderTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // business name
                            RecrNarrowInput(
                              controller: businessNameController,
                              inputHintText: "Good Taste Sdn Bhd",
                              iconPath: "assets/images/recruiter/business.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getBusinessNameTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // business address first line input
                            RecrNarrowInput(
                              controller: firstLineAddressController,
                              inputHintText: "123, Jalan SS 2/10",
                              iconPath:
                                  "assets/images/recruiter/address_first_line.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: true,
                              textInputType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              errorText: null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return LanguageConverterHelper
                                      .getAddressTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // business address states input
                            RecrNarrowDropDownInput(
                              inputHintTitle:
                                  LanguageConverterHelper.getAddressTextLang(
                                      widget.language),
                              iconPath: "assets/images/states/selangor.png",
                              selectedValue: selectedMalaysiaStatesValue,
                              map: malaysiaStatesMap,
                              onChanged: (value) {
                                setState(() {
                                  selectedMalaysiaStatesValue =
                                      value.toString();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return LanguageConverterHelper
                                      .getAddressTextLang(widget.language);
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // image
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 120.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: () {
                                        if (firstEntry == true) {
                                          return Colours.inputBorderColor;
                                        } else if (imageFile == null) {
                                          return Colors.red;
                                        } else {
                                          return Colours.inputBorderColor;
                                        }
                                      }(),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: () {
                                    if (imageFile != null) {
                                      return Image.memory(imageFile!);
                                    } else {
                                      return const SizedBox();
                                    }
                                  }(),
                                ),
                                if (firstEntry == true)
                                  const SizedBox()
                                else if (imageFile == null)
                                  Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        LanguageConverterHelper
                                            .getTakePhotoTextLang(
                                                widget.language),
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: Fonts
                                                .inputRecrErrorTextFontSize),
                                      ))
                                else
                                  const SizedBox(),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: () {
                                    if (firstEntry == true) {
                                      return Colors.transparent;
                                    } else if (imageFile == null) {
                                      return Colors.red;
                                    } else {
                                      return Colors.transparent;
                                    }
                                  }(),
                                  width: 5.0,
                                ),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: RecrNarrowButton(
                                buttonText: LanguageConverterHelper
                                    .getTakePhotoTextLang(widget.language),
                                color: Colours.primaryColor,
                                iconPath: "assets/images/recruiter/camera.png",
                                iconSecondPath:
                                    "assets/images/recruiter/selfie.png",
                                isSmallButton: true,
                                onPressed: takePhoto,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // sign up button
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: RecrNarrowButton(
                  buttonText: LanguageConverterHelper.getSignUpTextLang(
                      widget.language),
                  isSmallButton: false,
                  iconPath: "assets/images/recruiter/sign_up.png",
                  color: Colours.primaryColor,
                  onPressed: () async {
                    widget.audioPlayer.dispose();
                    setState(() {
                      firstEntry = false;
                    });

                    bool userExists = await isEmailExists();

                    if (userExists) {
                      setState(() {
                        invalidEmail = true;
                      });
                    } else {
                      setState(() {
                        invalidEmail = false;
                      });
                    }

                    // validation
                    if (formKey.currentState!.validate() && imageFile != null) {
                      final connectionCheckerHelper = ConnectionCheckerHelper();
                      bool hasConnection =
                          await connectionCheckerHelper.checkConnection();

                      if (hasConnection) {
                        setState(() {
                          loading = true;
                        });
                        await uploadImageUrlInFirebaseStorage();

                        final recruiter = Recruiters(
                            recruiterEmail: emailController.text.trim(),
                            mobileNum: mobileNumController.text.trim(),
                            name: nameController.text.trim(),
                            gender: selectedGenderValue.toString(),
                            businessName: businessNameController.text.trim(),
                            firstLineAddress:
                                firstLineAddressController.text.trim(),
                            states: selectedMalaysiaStatesValue.toString(),
                            image: imageUrl);

                        await createRecruiterFireAuth(recruiter);
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

  // create recruiter in fireauth
  Future createRecruiterFireAuth(Recruiters recruiter) async {
    setState(() {
      invalidEmail = false;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      await createRecruiterFireStore(recruiter);
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        setState(() {
          invalidEmail = true;
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

  // create recruiter in cloud firestore
  Future createRecruiterFireStore(Recruiters recruiter) async {
    try {
      final docRecruiter = FirebaseFirestore.instance
          .collection(Recruiters.collectionName)
          .doc(FirebaseAuth.instance.currentUser!.uid);
      recruiter.recruiterId = docRecruiter.id;
      final json = recruiter.toJson();
      await docRecruiter.set(json);
      await showDialogPrompt(
        true,
        "assets/images/successful.png",
        LanguageConverterHelper.getSignUpSuccessTextLang(widget.language),
      );
    } catch (e) {
      await showDialogPrompt(
        false,
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  Future<bool> isEmailExists() async {
    try {
      setState(() {
        invalidEmail = false;
      });

      var doc = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailController.text.trim());

      if (doc.length > 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> takePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    // return null if no images are selected / taken
    if (file == null) return;
    // compress the image
    Uint8List compressedImage = await compressImage(file);

    setState(() {
      imageFile = compressedImage;
    });
  }

  Future<void> uploadImageUrlInFirebaseStorage() async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      // store the file
      await referenceImageToUpload.putData(imageFile!);
      imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        imageUrl = imageUrl;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> compressImage(XFile file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 250,
      minHeight: 250,
      quality: 90,
      rotate: 0,
      format: CompressFormat.jpeg,
    );

    return result!;
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
