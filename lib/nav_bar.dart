import 'package:flutter/material.dart';
import 'home.dart'; // home.dartのインポート

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // ホームボタンが押されたら home.dart に遷移
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false, // 戻る操作を無効にする
                );
              },
              child: _buildNavItem(Icons.home, 'ホーム', Colors.blue),
            ),
            _buildNavItem(Icons.favorite_border, 'お気に入り', Colors.black),
            const SizedBox(
              width: 60,
              child: Text(
                'あいタク',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildNavItem(Icons.access_time, '予約一覧', Colors.black),
            _buildNavItem(Icons.phone, '緊急SOS', Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
