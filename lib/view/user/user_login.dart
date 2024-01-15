import 'dart:async';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/layout/loading.dart';
import 'package:ckfyp02/view/user/user_sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/users.dart';
import '../layout/input_field.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';
import '../layout/responsive_layout.dart';

class UserLoginView extends StatefulWidget {
  const UserLoginView({super.key});

  @override
  State<UserLoginView> createState() => _UserLoginViewState();
}

class _UserLoginViewState extends State<UserLoginView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        // user is logged in
        if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/userMainView',
              (route) => false,
            );
          });
        }
        // user is not logged in
        return Scaffold(
          resizeToAvoidBottomInset: false, // disable the bottom button pops up
          appBar: AppBar(
            title: const Text("Login"),
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
      },
    );
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == null) {
      return false;
    }
    return true;
  }
}

class NarrowLayout extends StatefulWidget {
  const NarrowLayout({super.key});

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
                            UserNarrowInput(
                              controller: emailController,
                              inputTitle: "Email",
                              inputHintText: "Enter Email:",
                              inputIcon: Icons.email,
                              isObscureText: false,
                              isEnableSuggestions: true,
                              isAutoCorrect: true,
                              textInputType: TextInputType.emailAddress,
                              errorText: invalidEmail ? "Invalid Email" : null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Email";
                                }

                                return null;
                              },
                            ),
                            // password input
                            const SizedBox(height: 20),
                            UserNarrowInput(
                              controller: passwordController,
                              inputTitle: "Password",
                              inputHintText: "Enter Password:",
                              inputIcon: Icons.lock,
                              isObscureText: true,
                              isEnableSuggestions: false,
                              isAutoCorrect: false,
                              textInputType: TextInputType.text,
                              errorText:
                                  invalidPassword ? "Invalid Password" : null,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Password";
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
                      child: UserNarrowButton(
                        buttonText: "Login",
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            bool userExists = await isUserExists();

                            if (userExists) {
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
                        color: Colours.primaryColor,
                        isSmallButton: false,
                        iconPath: "",
                      ),
                    ),
                    // sign up button
                    Container(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const UserSignUpView()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontFamily: Fonts.primaryFont,
                            fontSize: Fonts.primaryRecrFontSize,
                            decoration: TextDecoration.underline,
                            shadows: [
                              Shadow(
                                offset: Offset(0.5, 0.5),
                                blurRadius: 3.0,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        child: const Text("Sign Up"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Future<void> showDialogPrompt(
      String dialogTitle, String iconPath, String dialogMessage) async {
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
            UserNarrowButton(
              buttonText: "OK",
              onPressed: () {
                Navigator.of(context).pop();
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

  Future<void> login() async {
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
      prefs
          .setString('accountRole', Users.collectionName)
          .then((value) => Navigator.pushNamedAndRemoveUntil(
                context,
                '/userMainView',
                (route) => false,
              ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email" || e.code == "user-not-found") {
        setState(() {
          invalidEmail = true;
        });
      } else if (e.code == "wrong-password") {
        setState(() {
          invalidPassword = true;
        });
      } else {
        await showDialogPrompt(
            "Login Failed", "assets/images/unsuccessful.png", e.message!);
      }
    }
  }

  Future<bool> isUserExists() async {
    try {
      setState(() {
        invalidEmail = false;
      });

      var doc = await FirebaseFirestore.instance
          .collection(Users.collectionName)
          .where('userEmail', isEqualTo: emailController.text.trim())
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
  // Future<bool> isUserExists() async {
  //   try {
  //     setState(() {
  //       invalidEmail = false;
  //     });

  //     var doc = await FirebaseFirestore.instance
  //         .collection(Users.collectionName)
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
