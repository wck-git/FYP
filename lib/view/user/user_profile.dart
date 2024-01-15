import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckfyp02/view/layout/button.dart';
import 'package:ckfyp02/view/user/user_edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/users.dart';
import '../layout/responsive_layout.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import 'package:intl/intl.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colours.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // remove appbar back button
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
  const NarrowLayout({super.key});

  @override
  State<NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final User user = FirebaseAuth.instance.currentUser!;

  Users userDetails = Users(
      userEmail: '',
      mobileNum: '',
      name: '',
      gender: '',
      birthDate: DateTime.now().toUtc(),
      image: '');
  DateFormat dateFormatter = DateFormat("y-MM-dd");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Users.collectionName)
          .doc(user.uid)
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

        // fetch user details
        if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data();

          userDetails = Users.fromJson(userData!);
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
                      imageUrl: userDetails.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      width: 125.0,
                      height: 125.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  // name
                  Text(
                    userDetails.name,
                    style: const TextStyle(
                      fontFamily: Fonts.primaryFont,
                      fontSize: Fonts.profileTitleFontSize,
                      color: Colours.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // email
                      Container(
                        child: Text(
                          ('Email: ${userDetails.userEmail}'),
                          style: const TextStyle(
                            fontFamily: Fonts.primaryFont,
                            fontSize: Fonts.primaryFontSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // mobile num
                      Container(
                        child: Text(
                          ('Phone Number: ${userDetails.mobileNum}'),
                          style: const TextStyle(
                            fontFamily: Fonts.primaryFont,
                            fontSize: Fonts.primaryFontSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // gender
                      Container(
                        child: Text(
                          ('Gender: ${getGender(userDetails.gender)}'),
                          style: const TextStyle(
                            fontFamily: Fonts.primaryFont,
                            fontSize: Fonts.primaryFontSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // birth date
                      Container(
                        child: Text(
                          ('Birth Date: ${dateFormatter.format(userDetails.birthDate).toString()}'),
                          style: const TextStyle(
                            fontFamily: Fonts.primaryFont,
                            fontSize: Fonts.primaryFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // edit details button
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: UserNarrowButton(
                buttonText: "Edit Details",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserEditProfileView(
                                userDetails: userDetails,
                              )));
                },
                color: Colours.primaryColor,
                isSmallButton: false,
                iconPath: "",
              ),
            ),
            // log out button
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: UserNarrowButton(
                buttonText: "Logout",
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('isLoggedIn');
                  prefs.remove('accountRole');

                  await FirebaseAuth.instance
                      .signOut()
                      .then((value) => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/mainView',
                            (route) => false,
                          ));
                },
                color: Colours.feedbackIncorrectColor,
                isSmallButton: false,
                iconPath: "",
              ),
            )
          ],
        );
      },
    );
  }

  String getGender(userGender) {
    String gender = "Male";

    if (userGender == "Girl") {
      gender = "Female";
    }

    return gender;
  }
}

class WideLayout extends StatelessWidget {
  const WideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
