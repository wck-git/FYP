import 'package:flutter/material.dart';
import '../../helper/languagePreferences.dart';
import '../../model/language.dart';
import '../util/colours.dart';
import '../util/fonts.dart';
import '../util/images.dart';

class LanguageDropDownMenu extends StatelessWidget {
  final Function(String?)? onChanged;
  // final List<String> languageList = Language.languageList;
  final Map<String, String> languageMap = Language.languageMap;
  LanguagePreferencesHelper languagePreferencesHelper =
      LanguagePreferencesHelper();

  LanguageDropDownMenu({
    required this.onChanged,
  });

  // @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: languagePreferencesHelper.getSelectedLanguage(),
      builder: (context, snapshot) {
        return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.37,
          child: Align(
            alignment: Alignment.center,
            child: DropdownButtonFormField(
              value: snapshot.data,
              isExpanded: true,
              decoration: const InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              iconEnabledColor: Colors.white,
              iconSize: 32.5,
              dropdownColor: Colours.primaryColor,
              // items: languageList.map((language) {
              //   return DropdownMenuItem(
              //     value: language,
              //     child: Center(
              //       child: Text(
              //         language,
              //         style: const TextStyle(
              //           fontSize: Fonts.primaryRecrFontSize,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   );
              // }).toList(),
              items: languageMap
                  .map((String val, String iconPath) {
                    return MapEntry(
                        val,
                        DropdownMenuItem(
                          value: val,
                          child: Row(
                            children: [
                              Image.asset(iconPath, width: 32.5, height: 32.5),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  val,
                                  style: const TextStyle(
                                    fontSize: Fonts.primaryRecrFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ));
                  })
                  .values
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}
