
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  static const String userNameKey = 'user_name';

  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString(userNameKey) ?? '';
  }

  Future<bool> saveUserName(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(
      userNameKey,
      trimmedName,
    );

    if (saved) {
      userName.value = trimmedName;
    }

    return saved;
  }
}
