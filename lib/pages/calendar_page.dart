import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'homePage.dart';

class CalendarPage extends StatefulWidget {
  final List<Exam> exams;

  const CalendarPage({Key? key, required this.exams}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDay;
  DateTime? _focusedDay;

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Exam> getExamsForSelectedDay() {
    if (_selectedDay == null) {
      return [];
    }
    return widget.exams.where((exam) {
      return isSameDay(exam.date, _selectedDay!);
    }).toList();
  }
  List<Exam> _getEventsForDay(DateTime day) {
    return widget.exams.where((exam) => isSameDay(exam.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Page'),
      ),
      body: Center(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return _selectedDay != null && isSameDay(_selectedDay!, day ?? DateTime(0, 0, 0));
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              eventLoader: _getEventsForDay,
            ),
            const SizedBox(height: 20),
            const Text('Exams for Selected Day:'),
            Expanded(
              child: ExamListView(exams: getExamsForSelectedDay()),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamListView extends StatelessWidget {
  final List<Exam> exams;

  const ExamListView({Key? key, required this.exams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return exams.isEmpty
        ? const Center(child: Text('No exams for the selected day.'))
        : ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(exams[index].subject),
          subtitle: Text(
              'On: ${exams[index].formattedDate}, At: ${exams[index].time}:${exams[index].minutes}'),
        );
      },
    );
  }
}
