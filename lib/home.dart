import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'nav_bar.dart';
import 'search.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'reservation_confirmed.dart';

final storage = FlutterSecureStorage();

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // サーバーから受け取るデータ
  List<dynamic>? orderDetails;

  @override
  void initState() {
    super.initState();
    checkRequested();
  }

  // サーバーから注文詳細を取得する関数
  Future<void> checkRequested() async {
    try {
      String? token = await storage.read(key: "access_token");

      if (token == null) {
        throw Exception('認証トークンが見つかりません');
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['user_id'];

      final response = await http.get(
        Uri.parse('http://15.152.251.125:8000/check-requested/${userId}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orderDetails = data;
        });
      } else {
        setState(() {
          orderDetails = null;
        });
      }
    } catch (e) {
      setState(() {
        orderDetails = null;
      });
    }
  }

  Future<void> signOut() async {
    final url = Uri.parse('http://15.152.251.125:8000/signout');
    final token = await storage.read(key: 'jwt');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'jwt');
      Navigator.pushReplacementNamed(context, '/sign-in');
    } else {
      _showErrorDialog('サインアウトに失敗しました。もう一度お試しください。');
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('本当にサインアウトしますか？'),
          content: const Text('サインアウトすると、アカウントからログアウトされます。'),
          actions: [
            TextButton(
              child: const Text('キャンセル', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('サインアウト', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.user),
                        title: const Text("プロフィール"),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.cog),
                        title: const Text("設定"),
                        onTap: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: ListTile(
                        leading: const FaIcon(FontAwesomeIcons.signOutAlt),
                        title: const Text("サインアウト"),
                        onTap: () {
                          _showSignOutDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: 20),
                  child: const Text(
                    'ver.1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(child: Text('ホーム画面のコンテンツをここに配置してください')),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (orderDetails != null) _buildRequestedCard(orderDetails),
                const SizedBox(height: 16),
                if (orderDetails != null) _buildActionButtons(),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomBottomNavBar(
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: 'ホーム'),
              FABBottomAppBarItem(iconData: Icons.favorite, text: 'お気に入り'),
              FABBottomAppBarItem(iconData: Icons.schedule, text: '予約一覧'),
              FABBottomAppBarItem(iconData: Icons.phone, text: '緊急SOS'),
            ],
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              });
            },
            centerItem: const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventSelectorPage()),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0059),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'あいタク\nする',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestedCard(List<dynamic>? orderDetails) {
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

  Future<Map<String, dynamic>> Matching() async {
    try {
      // トークンを取得
      String? token = await storage.read(key: "access_token");

      if (token == null) {
        throw Exception('認証トークンが見つかりません');
      }

      // order_id と my_order_id をログに出力して確認
      print('Request order_id: ${orderDetails?[3]}');
      print('Request my_order_id: ${orderDetails?[5]}');

      // ordersテーブルのstatusを取得するAPIを呼び出す
      final response = await http.post(
        Uri.parse('http://15.152.251.125:8000/matching'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // トークンをヘッダーに追加
        },
        body: jsonEncode({
          'order_id': orderDetails?[3],
          'my_order_id': orderDetails?[5],
        }),
      );

      // ステータスコードとレスポンスボディをログに出力
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // ステータスを返す
      } else {
        throw Exception('Failed to fetch order status');
      }
    } catch (error) {
      throw Exception('Error in fetchOrderStatus: $error');
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // APIを呼び出してstatusを取得し、マッチングとメール送信
              Map<String, dynamic> orderDetails = await Matching();

              // メール送信のAPIを呼び出す
              await http.post(
                Uri.parse(
                    'http://15.152.251.125:8000/send-confirmation-email/${orderDetails['order_id']}'),
                headers: {
                  "Authorization":
                      "Bearer ${await storage.read(key: 'access_token')}",
                },
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationConfirmed(
                      orderId: orderDetails['order_id'],
                      myOrderId: orderDetails['my_order_id']),
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
}
