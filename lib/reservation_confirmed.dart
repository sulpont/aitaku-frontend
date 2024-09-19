import 'package:flutter/material.dart';

class ReservationConfirmed extends StatefulWidget {
  const ReservationConfirmed({Key? key}) : super(key: key);

  @override
  _ReservationConfirmed createState() => _ReservationConfirmed();
}

class _ReservationConfirmed extends State<ReservationConfirmed> {
  final List<String> steps = ['探す', '募集中', '予約確定', '待ち合わせ', '乗車'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('あいタク相手の候補'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context); // Back button action
          },
        ),
        actions: [
          const SizedBox(width: 24), // Empty space instead of button
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(), // Updated to use the same status header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '予約が確定しました。マッチしたユーザーをご確認ください。',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildCandidateCard(), // Display the candidate card
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Chat button action
                },
                child: const Text('チャットを表示する'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Updated to use the same bottom navigation bar
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
              _buildStepCircle('募集中', isActive: false, isCompleted: true),
              _buildStepLine(),
              _buildStepCircle('予約確定', isActive: true, isCompleted: false),
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

  Widget _buildCandidateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/placeholder.png'),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '候補者ネーム',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star, size: 16, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text(
                          '4.8 (32 レビュー)',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.attach_money, color: Colors.green),
                      SizedBox(width: 8),
                      Text('¥2,500', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Text(
                        '(1人あたり ¥625)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.access_time, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('18:30', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'こちらの候補者は、あなたの条件に最もマッチしています。レビューも高評価で、安心して乗車できる相手です。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
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
