import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static const _kSelectedLanguageCode = "com.larryeparks.teammate.selected_language_code";
  static const _kEnglishCode = "en";

  final _selectedLanguageCodeController = BehaviorSubject<String>();

  SharedPrefUtil._() {
    SharedPreferences.getInstance().then((preferences) {
      _loadSelectedLanguageCode(preferences);
    });
  }

  void _loadSelectedLanguageCode(SharedPreferences preferences) {
    final selectedLanguageCode = preferences.getString(_kSelectedLanguageCode) ?? _kEnglishCode;
    _selectedLanguageCodeController.add(selectedLanguageCode);
    print('[DEBUG] selectedLanguageCode=$selectedLanguageCode');
  }

  static final SharedPrefUtil instance = SharedPrefUtil._();

  ValueObservable<String> get selectedLanguageCode$ => _selectedLanguageCodeController.stream;

  Future<bool> saveSelectedLanguageCode(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    final result = await preferences.setString(_kSelectedLanguageCode, languageCode);
    if (result) {
      print('[DEBUG] saveSelectedLanguageCode(languageCode=$languageCode [success[');
    } else {
      print('[DEBUG] saveSelectedLanguageCode(languageCode=$languageCode [error]');
    }
    return result;
  }
}