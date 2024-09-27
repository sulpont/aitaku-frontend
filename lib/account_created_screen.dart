import 'dart:async'; // タイマー用
import 'package:flutter/material.dart';

class AccountCreatedDialog extends StatefulWidget {
  @override
  _AccountCreatedDialogState createState() => _AccountCreatedDialogState();
}

class _AccountCreatedDialogState extends State<AccountCreatedDialog> {
  @override
  void initState() {
    super.initState();
    // 5秒後にモーダルを閉じてからリダイレクト
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pop(); // まずモーダルを閉じる
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // バックボタンを無効にする
      onWillPop: () async => false,
      child: Dialog(
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
      ),
    );
  }
}
