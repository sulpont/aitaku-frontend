import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // トークンを安全に保存するためのライブラリ
import 'aitaku_candidate.dart'; // reservation_confirmed.dartをインポート
import 'aitaku_no_candidate.dart'; // 候補が見つからない場合の画面をインポート
import 'reservation_confirmed.dart';

class OpenForRecruitment extends StatelessWidget {
  final int orderId; // 注文IDを受け取る
  final Map<String, dynamic> orderData; // 注文データを受け取る
  final storage = FlutterSecureStorage(); // トークンを安全に保存・取得するためのインスタンス

  OpenForRecruitment({required this.orderId, required this.orderData});

  Future<List<dynamic>> fetchOrderStatus() async {
    try {
      // トークンを取得
      String? token = await storage.read(key: "access_token");

      if (token == null) {
        throw Exception('認証トークンが見つかりません');
      }

      print("GGA");
      print(orderData["status"]);

      // ordersテーブルのstatusを取得するAPIを呼び出す
      final response = await http.post(
        Uri.parse('http://15.152.251.125:8000/search-orders'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // トークンをヘッダーに追加
        },
        body: jsonEncode({
          'origin': orderData["origin"],
          'destination': orderData["destination"],
          'check_in_time': orderData["check_in_time"],
          'co_passenger': orderData["co_passenger"],
          'min_participants': orderData["min_participants"],
          'back_seat_passengers': orderData["back_seat_passengers"],
          'wants_female': orderData["wants_female"],
          'id_verification_status': orderData["id_verification_status"],
          'journey_type': orderData["journey_type"],
          'user_id': orderData["user_id"]
        }),
      );

      // ステータスコードとレスポンスボディをログに出力
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("GGGAAA");
        print(data);
        return data; // ステータスを返す
      } else {
        throw Exception('Failed to fetch order status');
      }
    } catch (error) {
      print('Error in fetchOrderStatus: $error');
      throw error; // エラーを再スローしてキャッチする
    }
  }

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
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // ローディングのイメージ
            const SizedBox(height: 20),
            const Text('あいタク候補が見つかりましたら通知されます。'), // テキスト
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // APIを呼び出してstatusを取得
                  List<dynamic> orderDetails = await fetchOrderStatus();
                  print("check-1");
                  // print(orderDetails[0]);
                  String status = "";
                  if (orderDetails.isNotEmpty) {
                    print('check-1A');
                    print(orderDetails[0]);
                    print(orderDetails[0][0]);
                    // status = orderDetails['matching_orders'][0]
                    //     [11]; // 11番目の要素が 'waiting'
                    status = orderDetails[0][11];
                  }

                  print("check-2");
                  print(orderId);
                  print("check-3");
                  if (status == 'matched') {
                    print('matched');
                    // statusが'matched'の場合、ReservationConfirmedへorderIdを渡して遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationConfirmed(
                            orderId: orderDetails[0][0], // orderIdを渡す
                            myOrderId: orderId // 自分のorder_id
                            ),
                      ),
                    );
                  } else if (orderDetails.isNotEmpty) {
                    print('Find Record!');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AitakuCandidate(
                            orderId: orderDetails[0][0], // orderIdを渡す
                            myOrderId: orderId // 自分のorder_id
                            ),
                      ),
                    );
                  } else {
                    print('un-matched');
                    // それ以外のstatusの場合、AitakuNoCandidateへorderIdを渡して遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AitakuNoCandidate(
                          orderId: 0, // orderIdを渡す
                        ),
                      ),
                    );
                  }
                } catch (error) {
                  // エラーハンドリング
                  print('Error: $error');
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('エラー'),
                        content: Text('ステータスを取得できませんでした: $error'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('閉じる'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('候補を表示'),
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
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite), onPressed: () {}),
          const SizedBox(width: 40), // Middle space for FloatingActionButton
          IconButton(icon: const Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
        ],
      ),
    );
  }
}
