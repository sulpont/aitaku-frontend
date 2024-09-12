import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'genre_selection_modal.dart';
import 'region_selection_modal.dart';

class FilterModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModal({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  Map<String, dynamic> filters = {
    'genre': <String>[],
    'region': <String>[], // List<String> に変更
    'startDate': DateTime.now(),
    'endDate': DateTime.now().add(const Duration(days: 30)),
  };

  bool showStartCalendar = false;
  bool showEndCalendar = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterSection(
                    'ジャンル',
                    filters['genre'].isEmpty
                        ? 'すべて'
                        : filters['genre'].join(', '),
                    _showGenreSelectionModal),
                _buildFilterSection(
                    '地域',
                    filters['region'].isEmpty
                        ? 'すべて'
                        : filters['region'].join(', '),
                    _showRegionSelectionModal),
                _buildDateSection(),
                if (showStartCalendar) _buildCalendar(true),
                if (showEndCalendar) _buildCalendar(false),
              ],
            ),
          ),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.grey),
          ),
          const Text(
            '絞り込み検索',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: _resetFilters,
            child: const Text(
              '条件リセット',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, dynamic value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value is List ? value.join(', ') : value.toString()),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showGenreSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GenreSelectionModal(
        initialSelectedGenres:
            List<String>.from(filters['genre']), // List<String> にキャスト
        onGenresSelected: (selectedGenres) {
          setState(() {
            filters['genre'] = selectedGenres;
          });
        },
      ),
    );
  }

  void _showRegionSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RegionSelectionModal(
        initialSelectedRegions: List<String>.from(filters['region']),
        onRegionsSelected: (selectedRegions) {
          setState(() {
            filters['region'] = selectedRegions;
          });
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '公演日',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateInput(
                '開始日',
                filters['startDate'],
                () => setState(() => showStartCalendar = !showStartCalendar),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('ー'),
            ),
            Expanded(
              child: _buildDateInput(
                '終了日',
                filters['endDate'],
                () => setState(() => showEndCalendar = !showEndCalendar),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateInput(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy/MM/dd').format(date)),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isStartDate) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: isStartDate ? filters['startDate'] : filters['endDate'],
      selectedDayPredicate: (day) => isSameDay(
          isStartDate ? filters['startDate'] : filters['endDate'], day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          if (isStartDate) {
            filters['startDate'] = selectedDay;
            showStartCalendar = false;
          } else {
            filters['endDate'] = selectedDay;
            showEndCalendar = false;
          }
        });
      },
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          widget.onApplyFilters(filters);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('検索する', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      filters = {
        'genre': <String>[],
        'region': <String>[], // 空のList<String>にリセット
        'startDate': DateTime.now(),
        'endDate': DateTime.now().add(const Duration(days: 30)),
      };
    });
  }
}
