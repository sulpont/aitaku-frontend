import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'nav_bar.dart'; // カスタムナビゲーションバーのインポート
import 'search.dart'; // search.dartのインポート

final storage = FlutterSecureStorage();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 現在のタブの選択状態を管理

  Future<void> signOut() async {
    final url = Uri.parse('http://15.152.251.125:8000/signout');
    final token = await storage.read(key: 'jwt');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'jwt'); // トークンを削除
      Navigator.pushReplacementNamed(context, '/sign-in'); // サインイン画面へ遷移
    } else {
      _showErrorDialog('サインアウトに失敗しました。もう一度お試しください。');
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('本当にサインアウトしますか？'),
          content: const Text('サインアウトすると、アカウントからログアウトされます。'),
          actions: [
            TextButton(
              child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            TextButton(
              child: const Text('サインアウト', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                signOut(); // サインアウト処理を実行
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // サイドメニューを閉じる
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.user),
                        title: const Text("プロフィール"),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.cog),
                        title: const Text("設定"),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.signOutAlt),
                        title: const Text("サインアウト"),
                        onTap: () {
                          _showSignOutDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: 20),
                  child: const Text(
                    'ver.1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(child: Text('ホーム画面のコンテンツをここに配置してください')),
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, // アイコンが上部にはみ出るように設定
        children: [
          CustomBottomNavBar(
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: 'ホーム'),
              FABBottomAppBarItem(iconData: Icons.favorite, text: 'お気に入り'),
              FABBottomAppBarItem(iconData: Icons.schedule, text: '予約一覧'),
              FABBottomAppBarItem(iconData: Icons.phone, text: '緊急SOS'),
            ],
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              });
            },
            centerItem: const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 40, // アイコンを上部に飛び出すように配置
            left: MediaQuery.of(context).size.width / 2 - 30, // 中央に配置
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventSelectorPage()),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0059), // 中央アイコンの背景色を変更
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi, // 中央アイコンをタクシーマークに変更
                      color: Colors.white, // アイコンの色
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'あいタク\nする',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
