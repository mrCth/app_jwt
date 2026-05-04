import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List<Anime> _items = [];
  bool _isLoading = true;

  // เรียกใช้ AuthService เพื่อตรวจสอบสถานะล็อกอิน
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // เริ่มต้นด้วยการตรวจสอบล็อกอินก่อนดึงข้อมูล
    _checkLoginAndFetchData();
  }

  // ฟังก์ชันตรวจสอบการล็อกอิน
  Future<void> _checkLoginAndFetchData() async {
    bool isLoggedIn = await _authService.isLoggedIn();

    // เช็คว่าหน้าจอยังเปิดอยู่ไหม
    if (!mounted) return;

    // ถ้าไม่ได้ล็อกอิน (ไม่มี Token)
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ACCESS DENIED. AUTHENTICATION REQUIRED.',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );

      // เตะผู้ใช้กลับไปหน้า Login และลบประวัติการเข้าชมหน้าก่อนๆ ทิ้ง
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return; // หยุดการทำงานของฟังก์ชันนี้ทันที
    }

    // ถ้าล็อกอินแล้ว ให้ดำเนินการดึงข้อมูลจาก API ต่อไป
    _fetchData();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<void> _fetchData() async {
    final url = Uri.parse(
      'https://api.jsonbin.io/v3/b/69f84966856a682189a38328',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Master-Key':
              r'$2a$10$DnXpKfFdyTajKiVjANOvxOaBd8ym8Puo3xvwyTUv/nRbuboN6F3ji',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['record']['animes'];

        setState(() {
          _items = list.map((json) => Anime.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        print("Error Code: ${response.statusCode}");
        print("Error Body: ${response.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Exception: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24.0),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final anime = _items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: Text(
                            '${anime.id}',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anime.title.toUpperCase(),
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'GENRE: ${anime.genre.toUpperCase()}',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
