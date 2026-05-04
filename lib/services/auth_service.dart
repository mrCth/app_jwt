import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';

class AuthService {
  static const String baseUrl = 'https://www.melivecode.com';
  static const String _tokenKey = 'access_token';

  // เพิ่มฟังก์ชันนี้ต่อจากฟังก์ชัน login ใน AuthService
  Future<LoginResponse> register({
    required String fname,
    required String lname,
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/create');
      final body = jsonEncode({
        'fname': fname,
        'lname': lname,
        'username': username,
        'password': password,
        'email': email,
        'avatar':
            'https://www.melivecode.com/users/none.png', // รูปโปรไฟล์เริ่มต้น
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return LoginResponse(
          status: 'ok',
          message: 'User created successfully',
        );
      }

      return LoginResponse(
        status: 'error',
        message: data['message'] ?? 'Failed to create user',
      );
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Connection error. Please check your internet',
      );
    }
  }

  // ฟังก์ชัน LOGIN หลัก
  Future<LoginResponse> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/login');
      final body = jsonEncode({
        'username': username,
        'password': password,
        'expiresIn': 60000,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        if (loginResponse.isValid) {
          await saveToken(loginResponse.accessToken!);
        }

        return loginResponse;
      }

      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Request failed';

      if (response.statusCode == 400) {
        return LoginResponse(
          status: 'error',
          message: 'Please enter both username and password',
        );
      } else if (response.statusCode == 401) {
        return LoginResponse(
          status: 'error',
          message: 'Invalid username or password',
        );
      }
      return LoginResponse(status: 'error', message: message);
    } catch (e) {
      return LoginResponse(
        status: 'error',
        message: 'Connection error. Please check your internet',
      );
    }
  }

  // บันทึก JWT token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // รับ token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ลบ token (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
