import 'package:ckfyp02/view/layout/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../helper/connectionChecker.dart';
import '../../model/users.dart';
import '../layout/button.dart';
import '../layout/input_field.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import 'package:intl/intl.dart'; // for date formatter
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserSignUpView extends StatefulWidget {
  const UserSignUpView({super.key});

  @override
  State<UserSignUpView> createState() => _UserSignUpViewState();
}

class _UserSignUpViewState extends State<UserSignUpView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // enable the bottom button pops up
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
        child: ResponsiveLayout(
          narrowLayout: NarrowLayout(),
          wideLayout: WideLayout(),
        ),
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileNumController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  bool invalidEmail = false;
  bool isSignUpSuccessful = false;
  DateFormat dateFormatter = DateFormat("y-MM-dd");
  String? selectedGenderValue;
  Map<String, Icon> genderMap = const {
    'Boy': Icon(
      Icons.male,
      size: Images.userNarrowInputIconWidth,
      color: Colours.secondaryColor,
    ),
    'Girl': Icon(
      Icons.female,
      size: Images.userNarrowInputIconWidth,
      color: Colors.pink,
    ),
  };
  String imageUrl = "";
  // File? imageFile;
  Uint8List? imageFile;
  bool firstEntry = true;
  bool loading = false;

  @override
  void dispose() {
    // avoid memory leakage
    formKey.currentState?.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileNumController.dispose();
    nameController.dispose();
    birthDateController.dispose();
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
                          // email input
                          UserNarrowInput(
                            controller: emailController,
                            inputTitle: "Email",
                            inputHintText: "Enter Email",
                            inputIcon: Icons.email,
                            isObscureText: false,
                            isEnableSuggestions: true,
                            isAutoCorrect: true,
                            textInputType: TextInputType.emailAddress,
                            errorText:
                                invalidEmail ? "Email is already taken" : null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Email";
                              }
                              bool emailIsValid = RegExp(
                                      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$',
                                      caseSensitive: false)
                                  .hasMatch(value);
                              if (!emailIsValid) {
                                return "Enter a valid email (abc@gmail.com)";
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // password input
                          UserNarrowInput(
                            controller: passwordController,
                            inputTitle: "Password",
                            inputHintText: "Enter Password",
                            inputIcon: Icons.lock,
                            isObscureText: true,
                            isEnableSuggestions: false,
                            isAutoCorrect: false,
                            textInputType: TextInputType.text,
                            errorText: null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Password";
                              } else if (value.length < 7) {
                                return "Length must be more than 6";
                              } else if (value.length > 15) {
                                return "Length must be less than 15";
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
                                return "Mobile Number Format: 0123456789";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                            textCapitalization: TextCapitalization.words,
                            errorText: null,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Nickname";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // gender input
                          UserNarrowDropDownInput(
                            inputTitle: "Select Gender",
                            selectedValue: selectedGenderValue,
                            map: genderMap,
                            onChanged: (value) {
                              setState(() {
                                selectedGenderValue = value.toString();
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Select Gender";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // birth date input
                          UserPickerInput(
                            inputTitle: "Birth Date",
                            inputHintTitle: "Select Birth Date",
                            icon: Icons.calendar_today,
                            controller: birthDateController,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime
                                    .now(), // date displays to user in the picker
                                firstDate:
                                    DateTime(2000), // previous supported year
                                lastDate: DateTime
                                    .now(), // last supported date in the picker
                              );
                              if (pickedDate != null) {
                                birthDateController.text = dateFormatter
                                    .format(pickedDate)
                                    .toString(); // format the date with the specified formatted
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Select Birth Date";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // image
                          const Text(
                            "Selfie",
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
                                      if (firstEntry == true) {
                                        return Colors.black;
                                      } else if (imageFile == null) {
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
                                    child: const Text(
                                      "Take a selfie",
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
                    ),
                  ],
                ),
              ),
              // sign up button
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: UserNarrowButton(
                  buttonText: "Sign Up",
                  onPressed: () async {
                    setState(() {
                      firstEntry = false;
                    });

                    bool emailExists = await isEmailExists();

                    if (emailExists) {
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
                        final user = Users(
                          userEmail: emailController.text.trim(),
                          mobileNum: mobileNumController.text.trim(),
                          name: nameController.text.trim(),
                          gender: selectedGenderValue.toString(),
                          birthDate:
                              DateTime.parse(birthDateController.text).toUtc(),
                          image: imageUrl,
                        );

                        await createUserFireAuth(user);
                      } else {
                        await showDialogPrompt(
                          false,
                          "Sign Up Failed",
                          "assets/images/unsuccessful.png",
                          "No WiFi connection",
                        );
                      }
                    }

                    setState(() {
                      loading = false;
                    });
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

  // create user in fireauth
  Future createUserFireAuth(Users user) async {
    setState(() {
      invalidEmail = false;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      await createUserFireStore(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        setState(() {
          invalidEmail = true;
        });
      } else {
        await showDialogPrompt(
          false,
          "Sign Up Failed",
          "assets/images/unsuccessful.png",
          e.message!,
        );
      }
    }
  }

  // create user in cloud firestore
  Future createUserFireStore(Users user) async {
    try {
      final docUser = FirebaseFirestore.instance
          .collection(Users.collectionName)
          .doc(FirebaseAuth.instance.currentUser!.uid);
      user.userId = docUser.id;
      final json = user.toJson();
      await docUser.set(json);

      await showDialogPrompt(
        true,
        "Sign Up Success",
        "assets/images/successful.png",
        "Sign Up Success",
      );
    } catch (e) {
      await showDialogPrompt(
        false,
        "Sign Up Failed",
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
      minWidth: 200,
      minHeight: 200,
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
