import 'package:shared_preferences/shared_preferences.dart';
import 'package:merema/features/auth/presentation/pages/login_page.dart';
import 'package:merema/main.dart';

abstract class AuthLocalService {
  Future<bool> isLoggedIn();

  Future<String> getToken();
  Future<String> getUserRole();

  Future<void> logout();
}

class AuthLocalServiceImpl implements AuthLocalService {
  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token.isNotEmpty;
  }

  @override
  Future<String> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('token') ?? '';
  }

  @override
  Future<String> getUserRole() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('userRole') ?? '';
  }

  @override
  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('userRole');
    navigationService.pushAndRemoveUntil(LoginPage.route(null));
  }
}
