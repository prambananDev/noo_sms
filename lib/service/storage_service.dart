// import 'package:get/get.dart';
// import 'package:noo_sms/models/user.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive/hive.dart';


// class StorageService extends GetxService {
//   late SharedPreferences _prefs;
//   late Box<dynamic> _userBox;

//   Future<StorageService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     _userBox = await Hive.openBox('userBox');
//     return this;
//   }

//   // User Related Storage
//   Future<void> saveUser(User user) async {
//     await _userBox.put('currentUser', user.toJson());
//     await _prefs.setInt('iduser', user.id ?? 0);
//     await _prefs.setString('username', user.username ?? '');
//     await _prefs.setString('name', user.name ?? '');
//     await _prefs.setString('so', user.so ?? '');
//     await _prefs.setString('bu', user.bu ?? '');
//     await _prefs.setInt('editApproval', user.editApproval ?? 0);
//   }

//   Future<User?> getUser() async {
//     final userData = _userBox.get('currentUser');
//     if (userData != null) {
//       return User.fromJson(Map<String, dynamic>.from(userData));
//     }
//     return null;
//   }

//   Future<void> clearUser() async {
//     await _userBox.delete('currentUser');
//     await _prefs.remove('iduser');
//     await _prefs.remove('username');
//     await _prefs.remove('name');
//     await _prefs.remove('so');
//     await _prefs.remove('bu');
//     await _prefs.remove('editApproval');
//   }

//   // Remember Me Related Storage
//   Future<void> saveCredentials(String username, String password) async {
//     await _prefs.setString('savedUsername', username);
//     await _prefs.setString('savedPassword', password);
//     await _prefs.setBool('rememberMe', true);
//   }

//   Future<void> clearCredentials() async {
//     await _prefs.remove('savedUsername');
//     await _prefs.remove('savedPassword');
//     await _prefs.setBool('rememberMe', false);
//   }

//   // Generic Storage Methods
//   Future<void> setString(String key, String value) async {
//     await _prefs.setString(key, value);
//   }

//   Future<void> setBool(String key, bool value) async {
//     await _prefs.setBool(key, value);
//   }

//   Future<void> setInt(String key, int value) async {
//     await _prefs.setInt(key, value);
//   }

//   Future<void> remove(String key) async {
//     await _prefs.remove(key);
//   }

//   String? getString(String key) => _prefs.getString(key);
//   bool? getBool(String key) => _prefs.getBool(key);
//   int? getInt(String key) => _prefs.getInt(key);
// }