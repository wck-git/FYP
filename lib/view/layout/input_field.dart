import 'package:flutter/material.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class UserNarrowInput extends StatelessWidget {
  final TextEditingController controller;
  final String inputTitle;
  final String inputHintText;
  final IconData inputIcon;
  final bool isObscureText;
  final bool isEnableSuggestions;
  final bool isAutoCorrect;
  final TextInputType textInputType;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;
  final String? errorText;

  UserNarrowInput({
    required this.controller,
    required this.inputTitle,
    required this.inputHintText,
    required this.inputIcon,
    required this.isObscureText,
    required this.isEnableSuggestions,
    required this.isAutoCorrect,
    required this.textInputType,
    this.textCapitalization,
    required this.validator,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Text(
            inputTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.primaryFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.left,
          obscureText: isObscureText,
          enableSuggestions: isEnableSuggestions,
          autocorrect: isAutoCorrect,
          keyboardType: textInputType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          validator: validator,
          decoration: InputDecoration(
            errorText: errorText,
            hintText: inputHintText,
            hintStyle: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.inputHintTextFontSize,
            ),
            prefixIcon: Icon(
              inputIcon,
              color: Colours.secondaryColor,
              size: Images.userNarrowInputIconWidth,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                width: 2.0,
                color: Colours.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UserNarrowDropDownInput extends StatelessWidget {
  final String inputTitle;
  Object? selectedValue;
  Map<String, Icon> map;
  Function(Object?) onChanged;
  final String? Function(Object?)? validator;

  UserNarrowDropDownInput({
    required this.inputTitle,
    required this.selectedValue,
    required this.map,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Text(
            inputTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.primaryFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        DropdownButtonFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.transgender,
              color: Colours.secondaryColor,
              size: Images.userNarrowInputIconWidth,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 2.0,
                color: Colours.primaryColor,
              ),
            ),
          ),
          validator: validator,
          value: selectedValue,
          hint: Text(
            inputTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.inputHintTextFontSize,
            ),
          ),
          isExpanded: true,
          items: map
              .map((String val, Icon icon) {
                return MapEntry(
                  val,
                  DropdownMenuItem(
                    value: val,
                    child: Row(
                      children: [
                        icon,
                        Text(val),
                      ],
                    ),
                  ),
                );
              })
              .values
              .toList(),
          onChanged: onChanged,
        )
      ],
    );
  }
}

class UserPickerInput extends StatelessWidget {
  final String inputTitle;
  final String inputHintTitle;
  final IconData icon;
  final TextEditingController controller;
  Function() onTap;
  final String? Function(String?)? validator;

  UserPickerInput({
    required this.inputTitle,
    required this.inputHintTitle,
    required this.icon,
    required this.controller,
    required this.onTap,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Text(
            inputTitle,
            style: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.primaryFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            labelText: inputHintTitle,
            labelStyle: const TextStyle(
              fontFamily: Fonts.primaryFont,
              fontSize: Fonts.inputHintTextFontSize,
            ),
            prefixIcon: Icon(
              icon,
              color: Colours.secondaryColor,
              size: Images.userNarrowInputIconWidth,
            ),
          ),
          readOnly: true,
          onTap: onTap,
          validator: validator,
        ),
      ],
    );
  }
}

class UserNarrowSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool? isReadOnly;
  final TextCapitalization textCapitalization;
  final Function()? onTap;

  const UserNarrowSearchBar({
    required this.controller,
    this.hintText,
    this.isReadOnly,
    required this.textCapitalization,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap ?? () {},
      readOnly: isReadOnly ?? false,
      controller: controller,
      textAlign: TextAlign.left,
      enableSuggestions: true,
      autocorrect: true,
      keyboardType: TextInputType.text,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hintText ?? "Search...",
        hintStyle: const TextStyle(
          fontFamily: Fonts.primaryFont,
          fontSize: Fonts.inputHintTextFontSize,
        ),
        contentPadding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.inputBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.primaryColor,
          ),
        ),
      ),
    );
  }
}

class RecrNarrowInput extends StatelessWidget {
  final TextEditingController controller;
  final String inputHintText;
  final String iconPath;
  final bool isObscureText;
  final bool isEnableSuggestions;
  final bool isAutoCorrect;
  final TextInputType textInputType;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;
  final String? errorText;

  RecrNarrowInput({
    required this.controller,
    required this.inputHintText,
    required this.iconPath,
    required this.isObscureText,
    required this.isEnableSuggestions,
    required this.isAutoCorrect,
    required this.textInputType,
    this.textCapitalization,
    required this.validator,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.left,
      obscureText: isObscureText,
      enableSuggestions: isEnableSuggestions,
      autocorrect: isAutoCorrect,
      keyboardType: textInputType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      validator: validator,
      style: const TextStyle(
        fontFamily: Fonts.primaryFont,
        fontSize: Fonts.inputRecrHintTextFontSize,
      ),
      decoration: InputDecoration(
        errorText: errorText,
        hintText: inputHintText,
        prefixText: ' ',
        hintStyle: const TextStyle(
          fontFamily: Fonts.primaryFont,
          fontSize: Fonts.inputRecrHintTextFontSize,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 7.5,
          ),
          child: Image.asset(iconPath,
              width: Images.recrNarrowInputIconWidth,
              height: Images.recrNarrowInputIconHeight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.inputBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: Fonts.inputRecrErrorTextFontSize,
        ),
      ),
    );
  }
}

class RecrNarrowDropDownInput extends StatelessWidget {
  final String inputHintTitle;
  final String iconPath;
  final Object? selectedValue;
  Map<String, Image> map;
  Function(Object?) onChanged;
  final String? Function(Object?)? validator;

  RecrNarrowDropDownInput({
    required this.inputHintTitle,
    required this.iconPath,
    this.selectedValue,
    required this.map,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        prefix: const Text(' '),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 7.5,
          ),
          child: Image.asset(iconPath,
              width: Images.recrNarrowInputIconWidth,
              height: Images.recrNarrowInputIconHeight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.inputBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: Fonts.inputRecrErrorTextFontSize,
        ),
      ),
      validator: validator,
      value: selectedValue,
      hint: Text(
        inputHintTitle,
        style: const TextStyle(
          fontFamily: Fonts.primaryFont,
          fontSize: Fonts.inputRecrHintTextFontSize,
        ),
      ),
      isExpanded: true,
      items: map
          .map((String val, Image icon) {
            return MapEntry(
                val,
                DropdownMenuItem(
                  value: val,
                  child: Row(
                    children: [
                      icon,
                      Text(
                        val,
                        style: const TextStyle(
                          fontFamily: Fonts.primaryFont,
                          fontSize: Fonts.inputRecrHintTextFontSize,
                        ),
                      ),
                    ],
                  ),
                ));
          })
          .values
          .toList(),
      onChanged: onChanged,
    );
  }
}

class RecrPickerInput extends StatelessWidget {
  final String inputHintTitle;
  final String iconPath;
  final TextEditingController controller;
  final bool hasTwoIcons;
  final String secondIconPath;
  Function() onTap;
  final String? Function(String?)? validator;

  RecrPickerInput({
    required this.inputHintTitle,
    required this.iconPath,
    required this.controller,
    required this.hasTwoIcons,
    required this.secondIconPath,
    required this.onTap,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontFamily: Fonts.primaryFont,
        fontSize: Fonts.inputRecrHintTextFontSize,
      ),
      decoration: InputDecoration(
        prefixText: ' ',
        labelText: inputHintTitle,
        labelStyle: const TextStyle(
          fontFamily: Fonts.primaryFont,
          fontSize: Fonts.inputRecrHintTextFontSize,
        ),
        prefixIcon: !hasTwoIcons
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 7.5,
                ),
                child: Image.asset(iconPath,
                    width: Images.recrNarrowInputIconWidth,
                    height: Images.recrNarrowInputIconHeight),
              )
            : Padding(
                padding: const EdgeInsets.only(
                  left: 7.5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(iconPath,
                        width: Images.recrNarrowInputIconWidth,
                        height: Images.recrNarrowInputIconHeight),
                    Image.asset(secondIconPath,
                        width: Images.recrNarrowInputIconWidth,
                        height: Images.recrNarrowInputIconHeight),
                  ],
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.inputBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.primaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 2.0,
            color: Colours.feedbackIncorrectColor,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: Fonts.inputRecrErrorTextFontSize,
        ),
      ),
      readOnly: true,
      onTap: onTap,
      validator: validator,
    );
  }
}
