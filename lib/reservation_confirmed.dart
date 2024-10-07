import 'dart:convert'; // JSON処理用
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // トークンを安全に保存するためのライブラリ

class ReservationConfirmed extends StatefulWidget {
  final int orderId; // orderId を追加
  final int myOrderId;

  ReservationConfirmed(
      {Key? key, required this.orderId, required this.myOrderId})
      : super(key: key); // コンストラクタに orderId を追加

  @override
  _ReservationConfirmed createState() => _ReservationConfirmed();
}

class _ReservationConfirmed extends State<ReservationConfirmed> {
  final List<String> steps = ['探す', '募集中', '予約確定', '待ち合わせ', '乗車'];
  final storage = FlutterSecureStorage(); // トークンを安全に保存・取得するためのインスタンス

  // サーバーから受け取るデータ
  List<dynamic>? orderDetails;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    print('initState');
    super.initState();
    fetchOrderDetails(); // 画面ロード時にサーバー通信を開始
  }

  // サーバーから注文詳細を取得する関数
  Future<void> fetchOrderDetails() async {
    print('fetchOrderDetails START');
    try {
      // トークンを取得
      String? token = await storage.read(key: "access_token");

      if (token == null) {
        throw Exception('認証トークンが見つかりません');
      }

      print(widget.orderId);
      final response = await http.get(
        Uri.parse('http://15.152.251.125:8000/orders/${widget.orderId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // トークンをヘッダーに追加
        },
      );

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコード
        print('response START');
        final data = json.decode(response.body);

        print(data);
        setState(() {
          orderDetails = data;
          isLoading = false; // データのロード完了
        });

        print('response200 END');
      } else {
        print('else START');
        setState(() {
          isLoading = false;
          errorMessage = 'サーバーからデータを取得できませんでした。';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'エラーが発生しました: $e';
      });
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // ローディング中はインジケータを表示
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // エラーメッセージを表示
              : Column(
                  children: [
                    _buildStatusHeader(),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '予約が確定しました。送信されたユーザーをご確認ください。',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildCandidateCard(
                        orderDetails), // Display the candidate card
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // チャットを表示する処理
                          },
                          child: const Text('チャットを表示する'),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildCandidateCard(List<dynamic>? orderDetails) {
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
                    Text(
                      orderDetails?[0], // orderDetailsから動的に取得した名前
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text(
                          '${orderDetails?[1]} (${orderDetails?[2]} レビュー)', // レビューの評価と件数を動的に表示
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
          const SizedBox(width: 40), // Middle space for FloatingActionButton
          IconButton(icon: Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: Icon(Icons.phone), onPressed: () {}),
        ],
      ),
    );
  }
}
