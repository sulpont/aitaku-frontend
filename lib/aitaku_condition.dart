import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSONデコード用
import 'open_for_recruitement.dart';

class AiTakuConditionSpecification extends StatefulWidget {
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
  String? friendCount = 'なし';
  String? minPeople = '2人';
  String? backSeat = '2人まで';
  bool femaleOnly = false;
  bool idVerified = true;
  String? selectedTime;
  String? tripType = '行き';
  String? departure = '選択してください'; // 初期値を '選択してください' に設定
  String? destination = '---';

  List<String> departureOptions = ['選択してください']; // プルダウンの最初に '選択してください' を追加
  List<String> destinationOptions = [];

  String eventName = '';
  String eventDescription = '';
  String eventDate = '';
  String eventLocation = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.initialTripType == '行き') {
      destination = widget.initialDestination ?? '---';
    } else if (widget.initialTripType == '帰り') {
      departure = widget.initialDestination ?? '選択してください';
      destination = widget.initialDeparture ?? '---';
    }

    fetchEventData(); // イベントデータを取得
  }

  Future<void> fetchEventData() async {
    final eventId = ModalRoute.of(context)?.settings.arguments as String?;
    if (eventId == null) {
      return;
    }

    final response =
        await http.get(Uri.parse('http://15.152.251.125:8000/events/$eventId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        eventName = data['event_title'];
        eventDescription = data['artist_name'];
        eventDate = data['start_time'];
        eventLocation = data['event_venue'];

        // 複数の出発地（check_in_places）を配列に格納
        departureOptions = ['選択してください']; // 最初に '選択してください' を表示
        departureOptions.addAll(List<String>.from(data['check_in_places']));
        destination = data['event_venue'];
        destinationOptions = [destination!];
      });
    }
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

              // 行き、帰り、往復の選択肢
              if (!widget.isReturnTrip)
                _buildSelection('行き・帰り・往復', ['行き', '帰り', '往復'], tripType,
                    (value) => setState(() => tripType = value),
                    baseColor: const Color(0xFFFF99A5))
              else
                const Text('帰り（復路）の条件を選択中', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // イベント詳細表示
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

              // 出発地と目的地のプルダウン表示
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

              // 女性限定・書類提出済みのスイッチ
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

              // 時刻選択
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
          onPressed: () {
            if (tripType == '往復') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AiTakuConditionSpecification(
                    initialDeparture: destination,
                    initialDestination: departure,
                    isReturnTrip: true,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OpenForRecruitment(),
                ),
              );
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
                isExpanded: true, // ドロップダウンのサイズを親に合わせる
                value: selected,
                onChanged: (newValue) {
                  setState(() {
                    if (label == '出発地') {
                      departure = newValue;
                    } else {
                      destination = newValue;
                    }
                  });
                },
                items: options.map<DropdownMenuItem<String>>((String value) {
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
