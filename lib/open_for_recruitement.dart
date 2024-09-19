import 'package:flutter/material.dart';
import 'aitaku_condition.dart'; // Import the file to reuse the bottom navigation bar
import 'aitaku_candidate.dart'; // Import the candidate screen

class OpenForRecruitment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('あいタク候補が見つかりましたら通知されます。'),
        actions: [
          TextButton(
            onPressed: () {
              // すべてクリアの処理を実装
            },
            child: const Text('すべてクリア', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildStatusHeader(),
            SizedBox(height: 20),
            CircularProgressIndicator(), // ローディングのイメージ
            SizedBox(height: 20),
            Text('あいタク候補が見つかりましたら通知されます。'), // テキスト
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AitakuCandidate()),
                );
              },
              child: Text('候補を表示'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ステップの丸とラインを表現
        Expanded(
          child: Row(
            children: [
              _buildStepCircle('探す', isActive: false, isCompleted: true),
              _buildStepLine(),
              _buildStepCircle('募集中', isActive: true, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('予約確定', isActive: false, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('待ち合わせ', isActive: false, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('乗車', isActive: false, isCompleted: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildStepCircle(String label,
      {required bool isActive, required bool isCompleted}) {
    Color circleColor;
    if (isCompleted) {
      circleColor = Colors.green;
    } else if (isActive) {
      circleColor = Colors.blue;
    } else {
      circleColor = Colors.grey;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: circleColor,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.white,
            child: isActive
                ? const Icon(Icons.circle, size: 8, color: Colors.blue)
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Colors.blue
                    : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home), onPressed: () {}),
          IconButton(icon: Icon(Icons.favorite), onPressed: () {}),
          SizedBox(width: 40), // Middle space for FloatingActionButton
          IconButton(icon: Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: Icon(Icons.phone), onPressed: () {}),
        ],
      ),
    );
  }
}
