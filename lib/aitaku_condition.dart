import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSONデコード用
import 'open_for_recruitment.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // トークンを安全に保存するために使用

class AiTakuConditionSpecification extends StatefulWidget {
  final int eventId; // イベントIDを受け取る
  final String? initialDeparture;
  final String? initialDestination;
  final String? initialFriendCount;
  final String? initialMinPeople;
  final String? initialBackSeat;
  final bool? initialFemaleOnly;
  final bool? initialIdVerified;
  final String? initialSelectedTime;
  final String? initialTripType;
  final bool isReturnTrip;

  const AiTakuConditionSpecification({
    Key? key,
    required this.eventId, // イベントIDを受け取る
    this.initialDeparture,
    this.initialDestination,
    this.initialFriendCount,
    this.initialMinPeople,
    this.initialBackSeat,
    this.initialFemaleOnly,
    this.initialIdVerified,
    this.initialSelectedTime,
    this.initialTripType,
    this.isReturnTrip = false,
  }) : super(key: key);

  @override
  _AiTakuConditionSpecificationState createState() =>
      _AiTakuConditionSpecificationState();
}

class _AiTakuConditionSpecificationState
    extends State<AiTakuConditionSpecification> {
  final storage = FlutterSecureStorage(); // トークンを保存・取得するためのインスタンス

  String? friendCount = 'なし';
  String? minPeople = '2人';
  String? backSeat = '2人まで';
  bool femaleOnly = false;
  bool idVerified = true;
  String? selectedTime;
  String? tripType = '行き（往路）'; // デフォルトは "行き（往路）"
  String? departure = '選択してください'; // 初期値を '選択してください' に設定
  String? destination = '---'; // 初期値を '---' に設定

  List<String> departureOptions = ['選択してください']; // プルダウンの最初に '選択してください' を追加
  List<String> destinationOptions = [];

  String eventName = '';
  String eventDescription = '';
  String eventDate = '';
  String eventLocation = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchEventData(); // イベントデータを取得
  }

  Future<void> fetchEventData() async {
    final response = await http.get(Uri.parse(
        'http://15.152.251.125:8000/events/${widget.eventId}')); // 渡されたevent_idを使用

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        eventName = data['event_title'];
        eventDescription = data['artist_name'];
        eventDate = data['start_time'];
        eventLocation = data['event_venue'];

        // 行きの初期設定: 目的地はイベント会場、出発地は check_in_places
        if (tripType == '行き（往路）') {
          destination = eventLocation; // 行きの目的地は event_venue
          destinationOptions = [eventLocation]; // 行きの時は選択肢は1つだけ
          departureOptions = ['選択してください'];
          departureOptions.addAll(List<String>.from(
              data['check_in_places'])); // 行きの出発地は check_in_places
        }
      });
    }
  }

  // 日付と時間を組み合わせて、"YYYY-MM-DD HH:MM" 形式に変換
  String combineDateAndTime(String time) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return '$formattedDate $time';
  }

  Future<void> createOrder() async {
    final url = Uri.parse('http://15.152.251.125:8000/orders/');

    // 数字を抽出して変換する関数（正規表現を使用）
    int parseNumber(String value) {
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) {
        return int.parse(match.group(0)!);
      } else {
        throw FormatException('無効な数字が含まれています');
      }
    }

    final combinedCheckInTime = combineDateAndTime(selectedTime ?? '12:00');

    try {
      // トークンを取得
      String? token = await storage.read(key: "access_token");
      String? userId = await storage.read(key: "user_id"); // user_idの取得

      if (token == null || userId == null) {
        print('トークンまたはユーザーIDがnullです。token: $token, userId: $userId');
        throw Exception('トークンまたはユーザーIDが見つかりません');
      }

      print('トークン: $token, ユーザーID: $userId');

      // 日本語の旅程タイプを英語に変換
      final journeyType = tripType == '行き（往路）'
          ? 'outward'
          : tripType == '帰り（復路）'
              ? 'return'
              : 'round_trip';

      // orderDataとしてリクエストボディを定義
      final orderData = {
        "user_id": int.parse(userId), // ユーザーIDを追加
        "event_id": widget.eventId, // 渡されたevent_idを使用
        "origin": departure,
        "destination": destination,
        "check_in_time": combinedCheckInTime, // 修正後の日時を使用
        "co_passenger": friendCount == 'なし' ? 0 : parseNumber(friendCount!),
        "min_participants": parseNumber(minPeople!),
        "back_seat_passengers": parseNumber(backSeat!),
        "wants_female": femaleOnly,
        "id_verification_status": idVerified ? "verified" : "unverified",
        "journey_type": journeyType, // 英語の旅程タイプを設定
        "status": "waiting" // ステータスを "waiting" に設定
      };

      // リクエストボディの内容をログに出力
      print('リクエストボディ: ${json.encode(orderData)}');

      // POSTリクエストを送信
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // トークンをヘッダーに含める
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderId = data['order_id']; // orderIdを取得

        // orderIdとorderDataをOpenForRecruitmentに渡して遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpenForRecruitment(
              orderId: orderId,
              orderData: orderData, // ここでorderDataを渡す
            ),
          ),
        );
      } else {
        print('サーバーレスポンス: ${response.statusCode} ${response.body}');
        throw Exception('注文の作成に失敗しました');
      }
    } catch (error) {
      print('注文の作成に失敗しました: $error');
    }
  }

  void _onTripTypeChanged(String? newTripType) {
    setState(() {
      if (newTripType == '帰り（復路）') {
        departure = eventLocation;
        departureOptions = [eventLocation]; // 出発地をイベント会場に固定
        destinationOptions = ['選択してください'];
        destinationOptions.addAll(List<String>.from(
            departureOptions.where((place) => place != '選択してください')));
        destination = '選択してください';
      } else if (newTripType == '行き（往路）') {
        destination = eventLocation;
        destinationOptions = [eventLocation]; // 行きの目的地は event_venue のみ
        departure = '選択してください';
        departureOptions = ['選択してください'];
        fetchEventData();
      }
      tripType = newTripType!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          '条件を指定する',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                departure = '選択してください';
                destination = '---';
              });
            },
            child: const Text(
              'すべてクリア',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(),
              const SizedBox(height: 8),
              if (!widget.isReturnTrip)
                _buildSelection('', ['行き（往路）', '帰り（復路）', '往復'], tripType,
                    (value) => _onTripTypeChanged(value),
                    baseColor: const Color(0xFFFF99A5))
              else
                const Text('帰り（復路）の条件を選択中', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName, style: const TextStyle(fontSize: 24)),
                  Text(
                    eventDescription,
                    style: const TextStyle(fontSize: 20, color: Colors.pink),
                  ),
                  Text('$eventDate $eventLocation',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown('出発地', departureOptions, departure),
              const SizedBox(height: 12),
              _buildDropdown('目的地', destinationOptions, destination),
              const SizedBox(height: 12),
              _buildSelection('お友達の人数', ['なし', '1人', '2人', '3人'], friendCount,
                  (value) => setState(() => friendCount = value),
                  baseColor: Colors.blue),
              const SizedBox(height: 12),
              _buildSelection('最小人数', ['2人', '3人', '4人'], minPeople,
                  (value) => setState(() => minPeople = value),
                  baseColor: Colors.blue),
              const SizedBox(height: 12),
              _buildSelection('後部座席', ['2人まで', '3人でも可'], backSeat,
                  (value) => setState(() => backSeat = value),
                  baseColor: Colors.blue),
              const SizedBox(height: 12),
              _buildSwitch('女性限定', femaleOnly, (value) {
                setState(() {
                  femaleOnly = value;
                });
              }, switchColor: Colors.green),
              const SizedBox(height: 12),
              _buildSwitch('本人確認書類提出済み', idVerified, (value) {
                setState(() {
                  idVerified = value;
                });
              }, switchColor: Colors.green),
              const SizedBox(height: 12),
              _buildTimePicker(),
              const SizedBox(height: 12),
              _buildActionButton()
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (tripType == '往復') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AiTakuConditionSpecification(
                    eventId: widget.eventId, // イベントIDを渡す
                    initialDeparture: destination,
                    initialDestination: departure,
                    isReturnTrip: true,
                  ),
                ),
              );
            } else {
              await createOrder(); // 注文を作成するAPIリクエストを送信
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0059),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            tripType == '往復' ? '帰り（復路）を指定する' : '募集する',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: options.contains(selected) ? selected : null,
                onChanged: (newValue) {
                  setState(() {
                    if (label == '出発地') {
                      departure = newValue;
                    } else {
                      destination = newValue;
                    }
                  });
                },
                items: options
                    .toSet()
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelection(String label, List<String> options, String? selected,
      Function(String) onSelected,
      {required Color baseColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selected == option,
              selectedColor: baseColor,
              onSelected: (bool isSelected) {
                onSelected(option);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool switchValue, Function(bool) onChanged,
      {required Color switchColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Switch(
          value: switchValue,
          onChanged: onChanged,
          activeColor: switchColor,
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    List<String> hours =
        List.generate(24, (index) => index.toString().padLeft(2, '0'));
    List<String> minutes = ['00', '15', '30', '45'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('希望待ち合わせ時刻', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedTime?.split(':')[0],
                    hint: const Text('--'),
                    onChanged: (newValue) {
                      setState(() {
                        selectedTime = newValue != null && selectedTime != null
                            ? '$newValue:${selectedTime!.split(':')[1]}'
                            : '$newValue:00';
                      });
                    },
                    items: hours.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text('時'),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedTime?.split(':')[1],
                    hint: const Text('--'),
                    onChanged: (newValue) {
                      setState(() {
                        selectedTime = selectedTime != null
                            ? '${selectedTime!.split(':')[0]}:$newValue'
                            : '00:$newValue';
                      });
                    },
                    items:
                        minutes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Text('分'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildStepCircle('探す', isActive: true, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('募集中', isActive: false, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('予約確定', isActive: false, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('待ち合わせ', isActive: false, isCompleted: false),
              _buildStepLine(),
              _buildStepCircle('乗車', isActive: false, isCompleted: true),
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
          const SizedBox(width: 40),
          IconButton(icon: const Icon(Icons.access_time), onPressed: () {}),
          IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
        ],
      ),
    );
  }
}
