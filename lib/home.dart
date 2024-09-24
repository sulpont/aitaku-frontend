import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // 最初に選択されるタブ（あいタクする）

  // タブの内容を表示するためのメソッド
  final List<Widget> _pages = [
    Container(color: Colors.white), // ホームタブ (空のコンテナ)
    Container(color: Colors.white), // お気に入りタブ (空のコンテナ)
    Container(color: Colors.white), // あいタクするタブ (空のコンテナ)
    Container(color: Colors.white), // 予約一覧タブ (空のコンテナ)
    Container(color: Colors.white), // 緊急SOSタブ (空のコンテナ)
  ];

  // サインアウトの処理
  Future<void> signOut() async {
    final url = Uri.parse('http://15.152.251.125:8000/signout');
    final token = await storage.read(key: 'jwt');

    // サインアウトリクエストの送信
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // サインアウト成功
    if (response.statusCode == 200) {
      await storage.delete(key: 'jwt'); // トークンを削除
      Navigator.pushReplacementNamed(context, '/sign-in'); // サインイン画面へ遷移
    } else {
      // サインアウト失敗
      _showErrorDialog('サインアウトに失敗しました。もう一度お試しください。');
    }
  }

  // サインアウト確認ダイアログを表示するメソッド
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
                Navigator.of(context).pop(); // ダイアログを閉じる
                signOut(); // サインアウト処理を実行
              },
            ),
          ],
        );
      },
    );
  }

  // エラーダイアログを表示するメソッド
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
                Navigator.of(context).pop(); // ダイアログを閉じる
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
      backgroundColor: Colors.white, // 背景色を白に設定

      // Drawerを追加（サイドメニュー）
      drawer: Drawer(
        child: Container(
          color: Colors.white, // 全体の背景色を白に設定
          child: Column(
            children: [
              const SizedBox(height: 40), // 全体を少し下に移動させる

              // 戻るアローアイコン
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

              // メニューリスト（プロフィール・設定・サインアウト）
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.user),
                        title: const Text("プロフィール"),
                        onTap: () {
                          // プロフィール画面に遷移する処理を追加
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.cog),
                        title: const Text("設定"),
                        onTap: () {
                          // 設定画面に遷移する処理を追加
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.signOutAlt),
                        title: const Text("サインアウト"),
                        onTap: () {
                          // サインアウト確認ダイアログを表示
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

      // Drawer用のハンバーガーアイコンを表示
      body: Stack(
        children: [
          _pages[_currentIndex],
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

      // BottomNavigationBarを追加
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 2) {
              // あいタクするボタンが押されたら search.dart へ遷移
              Navigator.pushNamed(context, '/search');
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heart, color: Colors.black),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFFFF0059),
              child: FaIcon(FontAwesomeIcons.taxi, color: Colors.white),
            ),
            label: 'あいタクする',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clock, color: Colors.grey),
            label: '予約一覧',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.phone, color: Colors.black),
            label: '緊急SOS',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
