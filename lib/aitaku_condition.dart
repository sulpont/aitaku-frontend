import 'package:flutter/material.dart';

class AiTakuConditionSpecification extends StatefulWidget {
  const AiTakuConditionSpecification({Key? key}) : super(key: key);

  @override
  _AiTakuConditionSpecificationState createState() =>
      _AiTakuConditionSpecificationState();
}

class _AiTakuConditionSpecificationState
    extends State<AiTakuConditionSpecification> {
  String? friendCount;
  String? minPeople;
  String? backSeat;
  bool femaleOnly = false;
  bool idVerified = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('あいタク条件を指定'),
        actions: [
          TextButton(
            onPressed: () {
              // すべてクリアの処理を実装
            },
            child: Text('すべてクリア', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ステップ表示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: Colors.blue, radius: 5),
                      SizedBox(width: 4),
                      CircleAvatar(backgroundColor: Colors.grey, radius: 5),
                      CircleAvatar(backgroundColor: Colors.grey, radius: 5),
                      CircleAvatar(backgroundColor: Colors.grey, radius: 5),
                      CircleAvatar(backgroundColor: Colors.grey, radius: 5),
                    ],
                  ),
                  Row(
                    children: [
                      Text('探す', style: TextStyle(color: Colors.blue)),
                      Text(' / 募集中 / 予約確定 / 待ち合わせ / 乗車',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 行き・帰りの選択
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('行き（往路）',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                  Text('帰り（復路）', style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),

              // イベント詳細
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TWICE', style: TextStyle(fontSize: 24)),
                  Text(
                    'TWICE 5TH WORLD TOUR \'READY T...\'',
                    style: TextStyle(fontSize: 20, color: Colors.pink),
                  ),
                  Text('2024年7月27日(土) 神奈川／日産スタジアム',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),

              // 出発地選択
              _buildDropdown('出発地', ['東急東横線 菊名駅 中央改札前'], '東急東横線 菊名駅 中央改札前'),
              SizedBox(height: 16),

              // 目的地選択
              _buildDropdown('目的地', ['神奈川／日産スタジアム 北口'], '神奈川／日産スタジアム 北口'),
              SizedBox(height: 16),

              // お友達の人数
              _buildSelection('お友達の人数', ['なし', '1人', '2人', '3人'], friendCount,
                  (value) => setState(() => friendCount = value)),
              SizedBox(height: 16),

              // 最小人数
              _buildSelection('最小人数', ['2人', '3人', '4人'], minPeople,
                  (value) => setState(() => minPeople = value)),
              SizedBox(height: 16),

              // 後部座席
              _buildSelection('後部座席', ['2人まで', '3人でも可'], backSeat,
                  (value) => setState(() => backSeat = value)),
              SizedBox(height: 16),

              // 女性限定
              _buildSwitch('女性限定', femaleOnly, (value) {
                setState(() {
                  femaleOnly = value;
                });
              }),
              SizedBox(height: 16),

              // 本人確認書類提出済み
              _buildSwitch('本人確認書類提出済み', idVerified, (value) {
                setState(() {
                  idVerified = value;
                });
              }),
              SizedBox(height: 16),

              // 待ち合わせ時刻
              _buildTimePicker(),
              SizedBox(height: 16),

              // FareAndRecruitmentウィジェットを追加
              FareAndRecruitment(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('希望待ち合わせ時刻', style: TextStyle(fontSize: 16)),
        TextField(
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            hintText: 'HH:MM',
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

// 以下に追加

class FareAndRecruitment extends StatelessWidget {
  const FareAndRecruitment({super.key});

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // ボタンの背景色
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '募集する',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
