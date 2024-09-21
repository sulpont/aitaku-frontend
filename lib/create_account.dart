import 'dart:async'; // タイマー用
import 'dart:convert'; // JSONエンコード・デコード用
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  String? _selectedGender;
  bool _isPasswordVisible = false; // パスワード表示切り替え用
  final TextEditingController _emailController =
      TextEditingController(); // Eメールコントローラ
  final TextEditingController _passwordController =
      TextEditingController(); // パスワードコントローラ

  final List<String> _genderOptions = ['男性', '女性', 'その他', '回答しない'];

  // アカウント作成APIと連携する関数
  Future<void> _createAccount() async {
    // 入力された値を取得
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String gender = _selectedGender ?? '回答しない'; // 性別が未選択の場合デフォルト

    // APIエンドポイントのURL
    const String apiUrl =
        'http://15.152.251.125:8000/signup'; // ここにAPIエンドポイントを記入

    try {
      print(jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'sex': gender,
      }));
      // APIリクエストを送信
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'sex': gender,
        }),
      );

      if (response.statusCode == 200) {
        // アカウント作成成功時にモーダルを表示し、5秒後にリダイレクト
        showDialog(
          context: context,
          barrierDismissible: false, // ダイアログの外側をタップしても閉じない
          builder: (BuildContext context) {
            return AccountCreatedDialog(); // モーダルウィンドウとして表示
          },
        );

        // 5秒後にサインイン画面にリダイレクト
        Timer(Duration(seconds: 5), () {
          Navigator.pushReplacementNamed(
              context, '/sign-in'); // サインイン画面へのリダイレクト
        });
      } else {
        // アカウント作成失敗時の処理
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント作成に失敗しました: ${errorData["detail"]}')),
        );
      }
    } catch (error) {
      // エラー処理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 背景を真っ白に設定
      appBar: AppBar(
        title: const Text('アカウント作成'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eメールアドレス
            const Text('Eメールアドレス'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'aitaku@example.com',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // パスワード
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
            const SizedBox(height: 16),

            // 性別
            const Text('性別'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              decoration: InputDecoration(
                hintText: '選択してください',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // アカウント作成ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _createAccount(); // アカウント作成処理を呼び出す
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0059),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  '新しいアカウントを作成する',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
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

            // アイコンを横に並べる
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google アイコン (赤色)
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red, // Googleの赤色
                  ),
                  iconSize: 30,
                  onPressed: () {
                    // Googleサインイン処理
                  },
                ),
                const SizedBox(width: 16),

                // Facebook アイコン (青色)
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Color(0xFF1877F2), // Facebookの青色
                  ),
                  iconSize: 30,
                  onPressed: () {
                    // Facebookサインイン処理
                  },
                ),
                const SizedBox(width: 16),

                // Apple アイコン (黒色)
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.apple,
                    color: Colors.black, // Appleの黒色
                  ),
                  iconSize: 30,
                  onPressed: () {
                    // Appleサインイン処理
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // "アカウントをお持ちですか？" と "サインイン" を中央に表示
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('アカウントをお持ちですか？'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign-in'); // サインイン画面へ遷移
                    },
                    child: const Text(
                      'サインイン',
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

// モーダルウィンドウで表示するダイアログウィジェット
class AccountCreatedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text('アカウント作成が完了しました！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center),
            SizedBox(height: 10),
            Text(
              '5秒後に自動的にサインイン画面へ\nリダイレクトします。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
