import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home.dart'; // Home画面のインポート
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage(); // storageインスタンスの作成

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _errorMessage = ''; // エラーメッセージ表示用

  // サインインAPIと連携する関数
  Future<void> _signIn() async {
    // 入力された値を取得
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // APIエンドポイントのURL
    const String apiUrl = 'http://15.152.251.125:8000/token'; // APIのエンドポイント

    try {
      // APIリクエストを送信
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // サインイン成功時の処理 (home画面へ遷移)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen()), // Home画面へ遷移
        );
      } else {
        // サインイン失敗時の処理 (エラーメッセージ表示)
        setState(() {
          _errorMessage = 'メールアドレスまたはパスワードが間違っています。';
        });
      }
    } catch (error) {
      // エラー処理
      setState(() {
        _errorMessage = 'エラーが発生しました: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('サインイン'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 前の画面に戻る
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eメールアドレス'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'example@example.com',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('パスワード'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'パスワード',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // パスワード忘れ処理
                },
                child: const Text(
                  'パスワードを忘れた場合',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // エラーメッセージ表示
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // エラーメッセージとサインインボタンの間にスペースを追加
            SizedBox(height: 20), // ここで高さを指定

            // サインインボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signIn, // サインインボタンを押した時の処理
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0059),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'サインインする',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // サードパーティサインインオプション
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                      const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  iconSize: 30,
                  onPressed: () {
                    // Googleサインイン処理
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook,
                      color: Color(0xFF1877F2)),
                  iconSize: 30,
                  onPressed: () {
                    // Facebookサインイン処理
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon:
                      const FaIcon(FontAwesomeIcons.apple, color: Colors.black),
                  iconSize: 30,
                  onPressed: () {
                    // Appleサインイン処理
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // アカウント作成リンク
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('アカウントをお持ちではありませんか?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/create-account'); // サインアップ画面に遷移
                    },
                    child: const Text(
                      'サインアップ',
                      style: TextStyle(color: Color(0xFFFF0059)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
