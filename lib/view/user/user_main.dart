import 'package:ckfyp02/view/layout/bottom_nav_bar.dart';
import 'package:ckfyp02/view/user/user_bookmark.dart';
import 'package:ckfyp02/view/user/user_home.dart';
import 'package:ckfyp02/view/user/user_job_application.dart';
import 'package:ckfyp02/view/user/user_profile.dart';
import 'package:flutter/material.dart';

class UserMainView extends StatefulWidget {
  int index;

  UserMainView({
    required this.index,
  });

  @override
  State<UserMainView> createState() => _UserMainViewState();
}

class _UserMainViewState extends State<UserMainView> {
  int currentIndex = 0;
  final List<Widget> widgetList = [
    const UserHomeView(),
    const UserBookmarkView(),
    const UserJobApplicationView(),
    const UserProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetList[currentIndex],
      bottomNavigationBar: UserBottomNavBarView(
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        isAtMainPage: true,
      ),
    );
  }
}
