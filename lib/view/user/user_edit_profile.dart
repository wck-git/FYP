import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/user/user_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../helper/connectionChecker.dart';
import '../../model/users.dart';
import '../layout/bottom_nav_bar.dart';
import '../layout/button.dart';
import '../layout/input_field.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class UserEditProfileView extends StatefulWidget {
  final Users userDetails;

  UserEditProfileView({required this.userDetails});

  @override
  State<UserEditProfileView> createState() => _UserEditProfileViewState();
}

class _UserEditProfileViewState extends State<UserEditProfileView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(userDetails: widget.userDetails),
          wideLayout: WideLayout(),
        ),
      ),
      bottomNavigationBar: UserBottomNavBarView(
        currentIndex: currentIndex,
        onTap: (int index) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserMainView(index: index)));
        },
        isAtMainPage: false,
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final Users userDetails;
  NarrowLayout({required this.userDetails});

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User user = FirebaseAuth.instance.currentUser!;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumController = TextEditingController();
  String imageUrl = "";
  Uint8List? newImage;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController = TextEditingController(text: widget.userDetails.name);
      mobileNumController =
          TextEditingController(text: widget.userDetails.mobileNum);
      imageUrl = widget.userDetails.image;
    });
  }

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.dispose();
    nameController.dispose();
    mobileNumController.dispose();
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
                child: ListView(
                  shrinkWrap: true, // shrink the content to its original size
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // full name input
                          UserNarrowInput(
                            controller: nameController,
                            inputTitle: "Nickname",
                            inputHintText: "Enter Nickname",
                            inputIcon: Icons.person,
                            isObscureText: false,
                            isEnableSuggestions: true,
                            isAutoCorrect: false,
                            textInputType: TextInputType.text,
                            errorText: null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Nickname";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // mobile number input
                          UserNarrowInput(
                            controller: mobileNumController,
                            inputTitle: "Mobile Number",
                            inputHintText: "Enter Mobile Number",
                            inputIcon: Icons.phone,
                            isObscureText: false,
                            isEnableSuggestions: true,
                            isAutoCorrect: false,
                            textInputType: TextInputType.phone,
                            errorText: null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Mobile Number";
                              }
                              bool mobileNumIsValid =
                                  RegExp(r'^\d{10,12}$').hasMatch(value);
                              if (!mobileNumIsValid) {
                                return "Mobile Number Format: 0169802517";
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
                              const Text(
                                "Image",
                                style: TextStyle(
                                  fontFamily: Fonts.primaryFont,
                                  fontSize: Fonts.primaryFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 120.0,
                                    margin: const EdgeInsets.only(
                                      top: 10.0,
                                    ),
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
                                        child: const Text(
                                          "Take a Selfie",
                                          style: TextStyle(color: Colors.red),
                                        ))
                                  else
                                    const SizedBox(),
                                  const SizedBox(height: 10.0),
                                  ElevatedButton(
                                    onPressed: takePhoto,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120.0, 45.0),
                                      backgroundColor: Colours.primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      textStyle: const TextStyle(
                                        fontFamily: Fonts.primaryFont,
                                        fontSize: Fonts.primaryFontSize,
                                      ),
                                    ),
                                    child: const Text("Take a Selfie"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // edit details button
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: UserNarrowButton(
                  buttonText: "Edit Details",
                  onPressed: () async {
                    // validation
                    if (formKey.currentState!.validate()) {
                      final connectionCheckerHelper = ConnectionCheckerHelper();
                      bool hasConnection =
                          await connectionCheckerHelper.checkConnection();

                      if (hasConnection) {
                        setState(() {
                          loading = true;
                        });
                        await editDetails(nameController.text.trim(),
                            mobileNumController.text.trim());
                      } else {
                        await showDialogPrompt(
                          false,
                          "Edit Failed",
                          "assets/images/unsuccessful.png",
                          "No WiFi connection",
                        );
                      }

                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  color: Colours.primaryColor,
                  isSmallButton: false,
                  iconPath: "",
                ),
              ),
            ],
          );
  }

  Future<void> showDialogPrompt(bool isSuccess, String dialogTitle,
      String iconPath, String dialogMessage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            dialogTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.inputHintTextFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
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
              // text
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
            UserNarrowButton(
              buttonText: "OK",
              onPressed: () {
                if (isSuccess) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.of(context).pop();
                }
              },
              color: Colours.primaryColor,
              isSmallButton: false,
              iconPath: "",
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

  Future<void> editDetails(String newName, String newMobileNum) async {
    try {
      await FirebaseFirestore.instance
          .collection(Users.collectionName)
          .doc(user.uid)
          .update({
        'name': newName,
        'mobileNum': newMobileNum,
      });
      if (newImage != null) {
        await editImageFirebaseStorage();
      } else {
        await showDialogPrompt(
          true,
          "Edit Success",
          "assets/images/successful.png",
          "Edit Success",
        );
      }
    } catch (e) {
      await showDialogPrompt(
        false,
        "Edit Mobile Number Failed",
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  Future<void> editImageFirebaseStorage() async {
    Reference referenceImageToUpload =
        FirebaseStorage.instance.refFromURL(widget.userDetails.image);
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
        "Edit Image Failed",
        "assets/images/unsuccessful.png",
        e.toString(),
      );
    }
  }

  Future<void> editImageFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection(Users.collectionName)
          .doc(user.uid)
          .update({'image': imageUrl});
      await showDialogPrompt(
        true,
        "Edit Success",
        "assets/images/successful.png",
        "Edit Success",
      );
    } catch (e) {
      await showDialogPrompt(
        false,
        "Edit Image Failed",
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
