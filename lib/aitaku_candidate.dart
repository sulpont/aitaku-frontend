import 'dart:convert'; // JSON処理用
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // トークンを安全に保存するためのライブラリ
import 'approved_waiting.dart';

class AitakuCandidate extends StatefulWidget {
  final int orderId; // orderId を追加
  final int myOrderId;

  // AitakuCandidate({Key? key, required this.orderId})
  //     : super(key: key); // コンストラクタに orderId を追加
  AitakuCandidate(
      {required this.orderId, required this.myOrderId}); // コンストラクタに orderId を追加

  @override
  _AitakuCandidate createState() => _AitakuCandidate();
}

class _AitakuCandidate extends State<AitakuCandidate> {
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
          // "Authorization": "Bearer YOUR_TOKEN_HERE" // 必要に応じてトークンを追加
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

  Future<Map<String, dynamic>> UpdateAcceptOrder() async {
    print('UpdateAcceptOrder START');
    try {
      // トークンを取得
      String? token = await storage.read(key: "access_token");

      if (token == null) {
        throw Exception('認証トークンが見つかりません');
      }

      // ordersテーブルのstatusを取得するAPIを呼び出す
      final response = await http.post(
        Uri.parse('http://15.152.251.125:8000/update-accept-order'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // トークンをヘッダーに追加
        },
        body: jsonEncode({
          'order_id': widget.orderId,
          'my_order_id': widget.myOrderId,
        }),
      );

      // ステータスコードとレスポンスボディをログに出力
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
                        '候補者が見つかりました。ユーザーをご確認ください。',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildCandidateCard(orderDetails),
                            const SizedBox(height: 16),
                            _buildActionButtons(),
                          ],
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
                    // orderDetails[18] が動的データなので const を削除する
                    Text(
                      orderDetails?[0], // orderDetailsから動的に取得した名前
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text(
                          '${orderDetails?[1]} (${orderDetails?[2]} レビュー)', // レビューの評価と件数を動的に表示
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // APIを呼び出してstatusを取得
              Map<String, dynamic> orderDetails = await UpdateAcceptOrder();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ApprovedWaiting(orderId: widget.orderId), // 修正済み
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('承認する'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Reject action
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text('却下する'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Cancel action
            },
            child: const Text('キャンセルする'),
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
          const SizedBox(width: 40), // Middle space for FloatingActionButton
          IconButton(icon: Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: Icon(Icons.phone), onPressed: () {}),
        ],
      ),
    );
  }
}
