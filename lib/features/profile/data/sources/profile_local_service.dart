import 'dart:convert';
import 'package:merema/features/profile/data/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalService {
  Future<UserProfileModel?> getCachedUserProfile();
  Future<void> cacheUserProfile(UserProfileModel userProfile);
}

class ProfileLocalServiceImpl implements ProfileLocalService {
  static const String CACHED_USER_PROFILE = 'CACHED_USER_PROFILE';

  @override
  Future<UserProfileModel?> getCachedUserProfile() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final jsonString = sharedPreferences.getString(CACHED_USER_PROFILE);
    return jsonString != null
        ? UserProfileModel.fromJson(json.decode(jsonString))
        : null;
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel userProfile) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      CACHED_USER_PROFILE,
      json.encode(userProfile.toJson()),
    );
  }
}
