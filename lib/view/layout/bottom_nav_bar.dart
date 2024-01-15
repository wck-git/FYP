import 'package:ckfyp02/helper/languageConverter.dart';
import 'package:flutter/material.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class UserBottomNavBarView extends StatelessWidget {
  int currentIndex;
  final Function(int) onTap;
  final bool isAtMainPage;

  UserBottomNavBarView({
    required this.currentIndex,
    required this.onTap,
    required this.isAtMainPage,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      unselectedIconTheme:
          const IconThemeData(color: Colours.bottomNavBarIconColor),
      selectedIconTheme: !isAtMainPage
          ? const IconThemeData(color: Colours.bottomNavBarIconColor)
          : const IconThemeData(color: Colours.primaryColor),
      unselectedFontSize: Fonts.bottomNavBarUnselectedFontSize,
      selectedFontSize: !isAtMainPage
          ? Fonts.bottomNavBarUnselectedFontSize
          : Fonts.bottomNavBarSelectedFontSize,
      fixedColor: Colors.black,
      iconSize: Images.userNarrowBottomBarIconWidth,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          activeIcon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bookmark_outline,
          ),
          label: "Bookmark",
          activeIcon: Icon(Icons.bookmark_outlined),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.work_outline,
          ),
          label: "My Job",
          activeIcon: Icon(Icons.work_outlined),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_outline,
          ),
          label: "Profile",
          activeIcon: Icon(Icons.person_2),
        ),
      ],
    );
  }
}

class RecrBottomNavBarView extends StatelessWidget {
  bool isAtMainPage;
  final String language;
  final Function(int) onTap;

  RecrBottomNavBarView({
    required this.isAtMainPage,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colours.primaryColor,
      selectedFontSize: Fonts.primaryRecrFontSize,
      unselectedFontSize: Fonts.primaryRecrFontSize,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      iconSize: Images.recrNarrowBottomBarIconWidth,
      items: isAtMainPage
          ? [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/home.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowIconHeight,
                ),
                label: LanguageConverterHelper.getHomeTextLang(language),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/back.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowBottomBarIconHeight,
                ),
                label: LanguageConverterHelper.getBackTextLang(language),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/help.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowBottomBarIconHeight,
                ),
                label: LanguageConverterHelper.getHelpTextLang(language),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/profile.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowBottomBarIconHeight,
                ),
                label: LanguageConverterHelper.getProfileTextLang(language),
              ),
            ]
          : [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/back.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowBottomBarIconHeight,
                ),
                label: LanguageConverterHelper.getBackTextLang(language),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/recruiter/help.png",
                  width: Images.recrNarrowBottomBarIconWidth,
                  height: Images.recrNarrowBottomBarIconHeight,
                ),
                label: LanguageConverterHelper.getHelpTextLang(language),
              ),
            ],
      onTap: onTap,
    );
  }
}
