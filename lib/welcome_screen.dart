import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 背景を真っ白に設定
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50), // 上に余白を入れる
            Image.asset(
              'assets/images/welcome_screen.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            // ウェルカムメッセージ
            const Text(
              'あいタク',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'いまここで、近くの人と（仮）',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const Spacer(), // スペーサーで下部にボタンを寄せる
            // ボタン群
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-account');
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
                      color: Colors.white, // 文字色を白に設定
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-in');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    side: const BorderSide(color: Color(0xFFFF0059)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'サインイン',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFFF0059),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32), // ボタン下に少し余白
          ],
        ),
      ),
    );
  }
}
