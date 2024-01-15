import 'package:shared_preferences/shared_preferences.dart';
import '../model/language.dart';

class LanguagePreferencesHelper {
  String selectedLanguage = Language.english;

  Future<void> setSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    selectedLanguage = language;
  }

  Future<String> getSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedLanguage = prefs.getString('selectedLanguage');

    if (storedLanguage != null) {
      return storedLanguage;
    }

    return selectedLanguage;
  }
}
