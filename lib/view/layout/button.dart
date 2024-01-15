import 'package:flutter/material.dart';
import '../util/fonts.dart';
import '../util/images.dart';

// general button (for recruiter and user) - main page
class GeneralButton extends StatelessWidget {
  static const recrNarrowButtonWidth = double.infinity;
  static const recrNarrowButtonHeight = 65.0;
  final String iconPath;
  final String buttonText;
  final Color color;
  final Function() onPressed;

  GeneralButton({
    required this.iconPath,
    required this.buttonText,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, recrNarrowButtonHeight),
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 10.0,
          textStyle: const TextStyle(
            fontFamily: Fonts.primaryFont,
            fontSize: Fonts.primaryRecrFontSize,
          ),
        ),
        icon: Image.asset(
          iconPath,
          width: Images.recrNarrowIconWidth,
          height: Images.recrNarrowIconHeight,
        ),
        label: Text(buttonText),
      ),
    );
  }
}

// user button
class UserNarrowButton extends StatelessWidget {
  static const userNarrowButtonWidth = double.infinity;
  static const userNarrowButtonHeight = 45.0;
  static const userNarrowSmallButtonWidth = 120.0;
  static const userNarrowSmallButtonHeight = 45.0;
  final String buttonText;
  final Function() onPressed;
  final Color color;
  final bool isSmallButton;
  final String iconPath;

  UserNarrowButton({
    required this.buttonText,
    required this.onPressed,
    required this.color,
    required this.isSmallButton,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width:
      //     !isSmallButton ? userNarrowButtonWidth : userNarrowSmallButtonWidth,
      // height:
      //     !isSmallButton ? userNarrowButtonHeight : userNarrowSmallButtonHeight,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(
              3.0,
              0.75,
            ),
            blurRadius: 20.0,
            spreadRadius: 0.1,
          ), //BoxShadow
        ],
      ),
      child: !isSmallButton
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45.0),
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                textStyle: const TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(buttonText),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120.0, 45.0),
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                textStyle: const TextStyle(
                  fontFamily: Fonts.primaryFont,
                  fontSize: Fonts.primaryFontSize,
                ),
              ),
              icon: Image.asset(
                iconPath,
                width: Images.userNarrowIconWidth,
                height: Images.userNarrowIconHeight,
              ),
              label: Text(buttonText),
            ),
    );
  }
}

// recruiter button
class RecrNarrowButton extends StatelessWidget {
  static const recrNarrowButtonWidth = double.infinity;
  static const recrNarrowButtonHeight = 65.0;
  static const recrNarrowSmallButtonWidth = 200.0;
  static const recrNarrowSmallButtonHeight = 65.0;
  final String iconPath;
  final String? iconSecondPath;
  final String buttonText;
  final Color color;
  final bool isSmallButton;
  final Function() onPressed;

  RecrNarrowButton({
    required this.iconPath,
    this.iconSecondPath,
    required this.buttonText,
    required this.color,
    required this.isSmallButton,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: !isSmallButton
              ? const Size(double.infinity, recrNarrowButtonHeight)
              : const Size(
                  recrNarrowSmallButtonWidth, recrNarrowSmallButtonHeight),
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          textStyle: const TextStyle(
            fontFamily: Fonts.primaryFont,
            fontSize: Fonts.primaryFontSize,
          ),
        ),
        icon: iconSecondPath == null
            ? Image.asset(
                iconPath,
                width: Images.recrNarrowIconWidth,
                height: Images.recrNarrowIconHeight,
              )
            : Row(children: [
                Image.asset(
                  iconPath,
                  width: Images.recrNarrowIconWidth,
                  height: Images.recrNarrowIconHeight,
                ),
                const SizedBox(width: 5.0),
                Image.asset(
                  iconSecondPath!,
                  width: Images.recrNarrowIconWidth,
                  height: Images.recrNarrowIconHeight,
                ),
              ]),
        label: Text(
          buttonText,
          style: const TextStyle(
            fontFamily: Fonts.primaryFont,
            fontSize: Fonts.primaryRecrFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
