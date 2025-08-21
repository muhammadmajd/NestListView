import 'package:flutter/material.dart';
import 'dart:async';


class Session {
  Session(this.date, this.customer, this.amount);
  final DateTime date;
  final String customer;
  final int amount;
}
/// Вспомогательный класс для представления итоговой суммы за день в списке.
class DailyDataGroup {
  final DateTime date;
  final List<Session> sessions;
  final int totalAmount;

  DailyDataGroup({
    required this.date,
    required this.sessions,
    required this.totalAmount,
  });
}

class SessionRepository {
  Future<List<Session>> fetch() async {
    final List<Session> sessions = [];
    final startDate = DateTime(2025, 1, 1);
    // Моделирование большого набора данных (365 дней)
    for (int i = 0; i < 365; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final clientCount = 10 + i % 20; // Variable clients per day
      for (int j = 0; j < clientCount; j++) {
        sessions.add(Session(currentDate, 'Customer ${j + 1}', 100 + (j * 10)));
      }
    }
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    // Данные для примера
    /*return Future.value([
      Session(DateTime(2025, 7, 1), 'Customer A', 100),
      Session(DateTime(2025, 7, 1), 'Customer B', 200),
      Session(DateTime(2025, 7, 1), 'Customer C', 300),
      Session(DateTime(2025, 7, 2), 'Customer D', 300),
      Session(DateTime(2025, 7, 2), 'Customer E', 300),
      Session(DateTime(2025, 7, 2), 'Customer F', 300),
      Session(DateTime(2025, 7, 2), 'Customer A', 300),
      Session(DateTime(2025, 7, 3), 'Customer B', 300),
    ]);*/
    return sessions;
  }
}


void main() {
  runApp(MyApp(repository: SessionRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});
  final SessionRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Session List',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SessionListScreen(repository: repository),
      ),
    );
  }
}

// -- Экран Списка Сессий --

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key, required this.repository});
  final SessionRepository repository;

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  final List<DailyDataGroup> _dailyGroups = [];
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processDataIncrementally();
  }

  /// Processes data in chunks to avoid blocking the UI thread.
  Future<void> _processDataIncrementally() async {
    final rawData = await widget.repository.fetch();
    if (!mounted) return;

    // --- Part 1: Initial Grouping  ---
    final Map<DateTime, List<Session>> grouped = {};
    for (final session in rawData) {
      final dateKey = DateTime(session.date.year, session.date.month, session.date.day);
      (grouped[dateKey] ??= []).add(session);
    }
    final sortedDates = grouped.keys.toList()..sort();

    // --- Part 2: Incremental Processing and UI Update ---
    for (final date in sortedDates) {
      // Yield to the event loop. This is the KEY to a responsive UI.
      // It allows Flutter to handle other events (like rendering) before continuing.
      await Future.delayed(Duration.zero);

      if (!mounted) return; // Stop if the widget is no longer visible

      final sessionsForDate = grouped[date]!;
      final total = sessionsForDate.fold<int>(0, (sum, s) => sum + s.amount);

      // Update the UI with the newly processed day's data
      setState(() {
        _dailyGroups.add(DailyDataGroup(
          date: date,
          sessions: sessionsForDate,
          totalAmount: total,
        ));
      });
    }

    // Mark processing as complete
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator only if the list is empty AND we are still processing.
    if (_isProcessing && _dailyGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Display the list, which populates incrementally.
    return Container(
      padding: const EdgeInsets.only(top: 35.0),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _dailyGroups.length,
        itemBuilder: (context, index) {
          return _DailyGroupCard(
              key: ValueKey('daily_card_${_dailyGroups[index].date.toIso8601String()}'),// for testing
              dailyData: _dailyGroups[index]);
        },
      ),
    );
  }
}

// -- Виджеты для Элементов Списка --

class _DailyGroupCard extends StatelessWidget {
  const _DailyGroupCard({
    Key? key,
    required this.dailyData}): super(key: key);
  final DailyDataGroup dailyData;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateHeader(date: dailyData.date),
          ...dailyData.sessions.map((session) => _SessionTile(session: session)).toList(),
          _TotalTile(totalAmount: dailyData.totalAmount),
        ],
      ),
    );
  }
}
 /// Вспомогательный класс для форматирования даты
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final DateTime date;

  String _formatDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1))),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Text(session.customer),
          const Spacer(),
          Text(session.amount.toString()),
        ],
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({required this.totalAmount});
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(totalAmount.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}