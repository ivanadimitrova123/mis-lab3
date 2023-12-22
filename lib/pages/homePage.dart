import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab3/auth.dart';
import 'calendar_page.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  List<Exam> exams = [];
  TextEditingController subjectController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  bool isAddingExam = false;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget title() {
    return const Text('Колоквиуми и Испити');
  }

  Widget userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget buildAddExamSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: subjectController,
            decoration: const InputDecoration(labelText: 'Предмет'),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () => _selectDate(context),
            child: const Text('Избери Датум'),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: hourController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Час'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextField(
                  controller: minuteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Минути'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _addExam();
              setState(() {
                isAddingExam = false;
              });
            },
            child: const Text('Додади'),
          ),
          const Divider(
            thickness: 2.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addExam() {
    setState(() {
      exams.add(
        Exam(
          subject: subjectController.text,
          date: selectedDate,
          time: hourController.text,
          minutes: minuteController.text,
        ),
      );

      subjectController.clear();
      hourController.clear();
      minuteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title(),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(exams: exams),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                isAddingExam = true;
              });
            },
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (isAddingExam) buildAddExamSection(),
            Expanded(
              child: ExamGridView(exams: exams),
            ),
            const SizedBox(height: 20),
            userUid(),
            signOutButton(),
          ],
        ),
      ),
    );
  }
}

class ExamGridView extends StatelessWidget {
  final List<Exam> exams;

  const ExamGridView({Key? key, required this.exams}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return exams.isEmpty
        ? const Center(
      child: Text('Нема додадени колоквиуми.'),
    )
        : GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5.0,
          margin: EdgeInsets.only(
            left: index.isEven ? 16.0 : 8.0,
            right: index.isOdd ? 16.0 : 8.0,
            top: index < 2 ? 16.0 : 8.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Предмет: ${exams[index].subject}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'На: ${exams[index].formattedDate}. Во: ${exams[index].time} часот и ${exams[index].minutes} мин.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Exam {
  final String subject;
  final DateTime date;
  final String time;
  final String minutes;

  Exam({
    required this.subject,
    required this.date,
    required this.time,
    required this.minutes,
  }
  );
  String get formattedDate => DateFormat.yMd().format(date);

}
