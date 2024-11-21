// import 'dart:convert';

// import 'package:noo_sms/assets/constant/api_constant.dart';

// class AuthService {
//   static Future<Map<String, dynamic>> login(
//       String username, String password, String playerId) async {
//     try {
//       final String basicAuth =
//           'Basic ${base64Encode(utf8.encode('${ApiConstants.authUsername}:${ApiConstants.authPassword}'))}';

//       final urlPostLogin = '${baseURLDevelopment}${ApiConstants.loginEndpoint}?'
//           'username=$username&password=${password.replaceAll("#", "%23")}&playerId=$playerId';

//       final response = await http.post(
//         Uri.parse(urlPostLogin),
//         headers: {'authorization': basicAuth},
//       );

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         if (response.body.isEmpty) {
//           throw Exception('Empty response from server');
//         }
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to login: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Login Error: $e');
//       throw Exception('Error during login: $e');
//     }
//   }

//   static Map<String, String> getAuthHeaders() {
//     final String basicAuth =
//         'Basic ${base64Encode(utf8.encode('${ApiConstants.authUsername}:${ApiConstants.authPassword}'))}';
//     return {'authorization': basicAuth};
//   }
// }
