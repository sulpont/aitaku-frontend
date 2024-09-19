import 'package:flutter/material.dart';
import 'open_for_recruitement.dart'; // Import the file

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
  final String? initialEstimatedFare;
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
    this.initialEstimatedFare,
    this.isReturnTrip = false,
  }) : super(key: key);

  @override
  _AiTakuConditionSpecificationState createState() =>
      _AiTakuConditionSpecificationState();
}

class _AiTakuConditionSpecificationState
    extends State<AiTakuConditionSpecification> {
  String? friendCount = 'なし'; // Set default value to 'なし'
  String? minPeople = '2人'; // Set default value to '2人'
  String? backSeat = '2人まで'; // Set default value to '2人まで'
  bool femaleOnly = false;
  bool idVerified = true;
  String? selectedTime;
  String estimatedFare = '¥3000'; // 仮の値を設定
  String? tripType = '片道'; // Set default value to '片道'
  String? departure = '東急東横線 菊名駅 中央改札前';
  String? destination = '神奈川／日産スタジアム 北口';

  @override
  void initState() {
    super.initState();
    if (widget.initialDeparture != null) {
      departure = widget.initialDeparture;
    }
    if (widget.initialDestination != null) {
      destination = widget.initialDestination;
    }
    if (widget.initialFriendCount != null) {
      friendCount = widget.initialFriendCount;
    }
    if (widget.initialMinPeople != null) {
      minPeople = widget.initialMinPeople;
    }
    if (widget.initialBackSeat != null) {
      backSeat = widget.initialBackSeat;
    }
    if (widget.initialFemaleOnly != null) {
      femaleOnly = widget.initialFemaleOnly!;
    }
    if (widget.initialIdVerified != null) {
      idVerified = widget.initialIdVerified!;
    }
    if (widget.initialSelectedTime != null) {
      selectedTime = widget.initialSelectedTime;
    }
    if (widget.initialTripType != null) {
      tripType = widget.initialTripType;
    }
    if (widget.initialEstimatedFare != null) {
      estimatedFare = widget.initialEstimatedFare!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('あいタク条件を指定'),
        actions: [
          TextButton(
            onPressed: () {
              // すべてクリアの処理を実装
            },
            child: const Text('すべてクリア', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ステップ表示（デザインを修正）
              _buildStatusHeader(),
              const SizedBox(height: 16),

              // 片道・往復の選択を追加
              if (!widget.isReturnTrip)
                _buildSelection('片道・往復', ['片道', '往復'], tripType,
                    (value) => setState(() => tripType = value))
              else
                const Text('復路の条件を選択中', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // イベント詳細
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('TWICE', style: TextStyle(fontSize: 24)),
                  Text(
                    'TWICE 5TH WORLD TOUR \'READY T...\'',
                    style: TextStyle(fontSize: 20, color: Colors.pink),
                  ),
                  Text('2024年7月27日(土) 神奈川／日産スタジアム',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),

              // 出発地選択
              _buildDropdown('出発地', [departure!], departure!),
              const SizedBox(height: 16),

              // 目的地選択
              _buildDropdown('目的地', [destination!], destination!),
              const SizedBox(height: 16),

              // お友達の人数
              _buildSelection('お友達の人数', ['なし', '1人', '2人', '3人'], friendCount,
                  (value) => setState(() => friendCount = value)),
              const SizedBox(height: 16),

              // 最小人数
              _buildSelection('最小人数', ['2人', '3人', '4人'], minPeople,
                  (value) => setState(() => minPeople = value)),
              const SizedBox(height: 16),

              // 後部座席
              _buildSelection('後部座席', ['2人まで', '3人でも可'], backSeat,
                  (value) => setState(() => backSeat = value)),
              const SizedBox(height: 16),

              // 女性限定
              _buildSwitch('女性限定', femaleOnly, (value) {
                setState(() {
                  femaleOnly = value;
                });
              }),
              const SizedBox(height: 16),

              // 本人確認書類提出済み
              _buildSwitch('本人確認書類提出済み', idVerified, (value) {
                setState(() {
                  idVerified = value;
                });
              }),
              const SizedBox(height: 16),

              // 待ち合わせ時刻
              _buildTimePicker(),
              const SizedBox(height: 16),

              // FareAndRecruitmentウィジェットを追加
              FareAndRecruitment(
                estimatedFare: estimatedFare,
                tripType: tripType!,
                isReturnTrip: widget.isReturnTrip,
                onReturnTripSelected: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AiTakuConditionSpecification(
                        initialDeparture: destination,
                        initialDestination: departure,
                        initialFriendCount: friendCount,
                        initialMinPeople: minPeople,
                        initialBackSeat: backSeat,
                        initialFemaleOnly: femaleOnly,
                        initialIdVerified: idVerified,
                        initialSelectedTime: selectedTime,
                        initialTripType: tripType,
                        initialEstimatedFare: estimatedFare,
                        isReturnTrip: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ステータスヘッダー部分を修正
  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ステップの丸とラインを表現
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

  Widget _buildDropdown(String label, List<String> options, String selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: selected,
          onChanged: (newValue) {
            setState(() {
              // 新しい値をセット
            });
          },
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelection(String label, List<String> options, String? selected,
      Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selected == option,
              onSelected: (bool selected) {
                onSelected(option);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    List<String> timeSlots = [];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        timeSlots.add(
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('希望待ち合わせ時刻', style: TextStyle(fontSize: 16)),
        DropdownButton<String>(
          value: selectedTime,
          hint: Text('選択してください'),
          onChanged: (newValue) {
            setState(() {
              selectedTime = newValue;
            });
          },
          items: timeSlots.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
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

// FareAndRecruitmentウィジェットを追加
class FareAndRecruitment extends StatelessWidget {
  final String estimatedFare;
  final String tripType;
  final bool isReturnTrip;
  final VoidCallback onReturnTripSelected;

  const FareAndRecruitment({
    super.key,
    required this.estimatedFare,
    required this.tripType,
    required this.isReturnTrip,
    required this.onReturnTripSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '想定運賃・',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                estimatedFare,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '同じ条件で探しているユーザーが3人います！',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isReturnTrip) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenForRecruitment(),
                    ),
                  );
                } else if (tripType == '往復') {
                  onReturnTripSelected();
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
                backgroundColor: Colors.blue, // ボタンの背景色
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isReturnTrip ? '募集する' : (tripType == '往復' ? '復路を指定' : '募集する'),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
