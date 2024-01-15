import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/recruiter/recruiter_home.dart';
import 'package:ckfyp02/view/recruiter/recruiter_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import '../../helper/connectionChecker.dart';
import '../../helper/languageConverter.dart';
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

class RecruiterEditProfileView extends StatefulWidget {
  final Recruiters recruiterDetails;

  RecruiterEditProfileView({
    required this.recruiterDetails,
  });

  @override
  State<RecruiterEditProfileView> createState() =>
      _RecruiterEditProfileViewState();
}

class _RecruiterEditProfileViewState extends State<RecruiterEditProfileView> {
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
              "assets/images/recruiter/sign_up.png",
              width: Images.recrNarrowIconWidth,
              height: Images.recrNarrowIconHeight,
            ),
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
            recruiterDetails: widget.recruiterDetails,
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
                  audioPath = "audio/en/edit_profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.chinese) {
                  audioPath = "audio/ch/edit_profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.bahasaMelayu) {
                  audioPath = "audio/bm/edit_profile.mp3";
                  audioPlayer.play(AssetSource(audioPath));
                } else if (language == Language.tamil) {
                  audioPath = "audio/tm/edit_profile.mp3";
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
  final Recruiters recruiterDetails;
  final AudioPlayer audioPlayer;
  final String language;
  final VoidCallback getLanguage;

  const NarrowLayout({
    required this.recruiterDetails,
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
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController firstLineAddressController = TextEditingController();
  String imageUrl = "";
  Uint8List? newImage;
  String? selectedMalaysiaStatesValue;
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
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController =
          TextEditingController(text: widget.recruiterDetails.name);
      mobileNumController =
          TextEditingController(text: widget.recruiterDetails.mobileNum);
      businessNameController =
          TextEditingController(text: widget.recruiterDetails.businessName);
      firstLineAddressController =
          TextEditingController(text: widget.recruiterDetails.firstLineAddress);
      selectedMalaysiaStatesValue = widget.recruiterDetails.states;
      imageUrl = widget.recruiterDetails.image;
    });
  }

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.reset();
    nameController.dispose();
    mobileNumController.dispose();
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
                            // name input
                            RecrNarrowInput(
                              controller: nameController,
                              inputHintText: "Tan Ah Lock",
                              iconPath: "assets/images/recruiter/name.png",
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
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
                            // phone number input
                            RecrNarrowInput(
                              controller: mobileNumController,
                              inputHintText: "0169802517",
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
                                  return "0169802517";
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
                              inputHintTitle: "Selangor",
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
                                        if (imageUrl == "") {
                                          return Colors.red;
                                        } else {
                                          return Colors.black;
                                        }
                                      }(),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: () {
                                    if (newImage != null) {
                                      return Image.memory(newImage!);
                                    } else if (imageUrl != "") {
                                      return CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        // userDetails.image,
                                        width: 125.0,
                                        height: 125.0,
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  }(),
                                ),
                                if (imageUrl == "")
                                  Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        LanguageConverterHelper
                                            .getTakePhotoTextLang(
                                                widget.language),
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ))
                                else
                                  const SizedBox(),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: () {
                                    if (imageUrl == "") {
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
                                buttonText: LanguageConverterHelper.getTakePhotoTextLang(widget.language),
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
              // edit details button
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: RecrNarrowButton(
                  buttonText: LanguageConverterHelper.getEditProfileTextLang(widget.language),
                  isSmallButton: false,
                  iconPath: "assets/images/recruiter/sign_up.png",
                  iconSecondPath: "assets/images/recruiter/profile.png",
                  color: Colours.primaryColor,
                  onPressed: () async {
                    widget.audioPlayer.dispose();
                    // validation
                    if (formKey.currentState!.validate()) {
                      final connectionCheckerHelper = ConnectionCheckerHelper();
                      bool hasConnection =
                          await connectionCheckerHelper.checkConnection();

                      if (hasConnection) {
                        setState(() {
                          loading = true;
                        });

                        await editDetails(
                          nameController.text.trim(),
                          mobileNumController.text.trim(),
                          businessNameController.text.trim(),
                          firstLineAddressController.text.trim(),
                          selectedMalaysiaStatesValue!,
                        );
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

  Future<void> takePhoto() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);

    // return null if no images are selected / taken
    if (file == null) return;
    // compress the image
    Uint8List compressedImage = await compressImage(file);

    setState(() {
      newImage = compressedImage;
    });
  }

  Future<void> editDetails(
      String newName,
      String newMobileNum,
      String newBusinessName,
      String newFirstLineAddress,
      String newStates) async {
    try {
      await FirebaseFirestore.instance
          .collection(Recruiters.collectionName)
          .doc(recruiter.uid)
          .update({
        'name': newName,
        'mobileNum': newMobileNum,
        'businessName': newBusinessName,
        'firstLineAddress': newFirstLineAddress,
        'states': newStates,
      });
      if (newImage != null) {
        await editImageFirebaseStorage();
      } else {
        await showDialogPrompt(
          true,
          "assets/images/successful.png",
          LanguageConverterHelper.getEditProfileSuccessTextLang(
              widget.language),
        );
      }
    } catch (e) {
      await showDialogPrompt(
        false,
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  Future<void> editImageFirebaseStorage() async {
    Reference referenceImageToUpload =
        FirebaseStorage.instance.refFromURL(widget.recruiterDetails.image);
    try {
      // store the file
      await referenceImageToUpload.putData(newImage!);
      imageUrl = await referenceImageToUpload.getDownloadURL();

      setState(() {
        imageUrl = imageUrl;
      });
      await editImageFirestore();
    } catch (e) {
      await showDialogPrompt(
        false,
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  Future<void> editImageFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection(Recruiters.collectionName)
          .doc(recruiter.uid)
          .update({'image': imageUrl});
      await showDialogPrompt(
        true,
        "assets/images/successful.png",
        LanguageConverterHelper.getEditProfileSuccessTextLang(widget.language),
      );
    } catch (e) {
      await showDialogPrompt(
        false,
        "assets/images/unsuccessful.png",
        e.toString(),
      );
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
    return const Placeholder();
  }
}
