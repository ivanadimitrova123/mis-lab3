import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab3/auth.dart';
import 'package:lab3/pages/notification_controller.dart';
import 'calendar_page.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  bool isAddingExam = false;
  LatLng userLocation = const LatLng(0, 0);


  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }



  @override
  void initState(){
    super.initState();
    getCurrentLocation();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: NotificationController.onDismissedReceivedMethod
    );
  }
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
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextField(
                  controller: longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Longitude'),
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
              AwesomeNotifications().createNotification(content: NotificationContent(
                id: 1,
                channelKey: "basic_channel",
                title: "Hello",
                body: "You have successfully added an exam",
              ),
              );
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
  Future<void> _addExam() async {
    setState(() {
      exams.add(
        Exam(
          subject: subjectController.text,
          date: selectedDate,
          time: hourController.text,
          minutes: minuteController.text,
          latitude: double.parse(latitudeController.text),
          longitude: double.parse(longitudeController.text),
        ),
      );

      subjectController.clear();
      hourController.clear();
      minuteController.clear();
      latitudeController.clear();
      longitudeController.clear();
    });

    double distanceInMeters = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      exams.last.latitude,
      exams.last.longitude,
    );

    if (distanceInMeters <= 100) {
      AwesomeNotifications().createNotification(content: NotificationContent(
        id: 2,
        channelKey: "basic_channel",
        title: "Location Reminder",
        body: "You have an upcoming exam near your current location",
      ));
    }

  }

  void launchGoogleMaps(List<Exam> exams) async {
    // Build the URL to open Google Maps with multiple markers
    String markers = exams.map((exam) {
      return "${exam.latitude},${exam.longitude}";
    }).join('&');

   String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$markers';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Handle error
    }
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
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              launchGoogleMaps(exams);
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

  void launchGoogleMapsDirections(Exam exam) async {
    String destination = '${exam.latitude},${exam.longitude}';
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$destination';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Handle error
    }
  }

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
                ElevatedButton(
                  onPressed: () {
                    launchGoogleMapsDirections(exams[index]);
                  },
                  child: const Text('Show Route'),
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
  final double latitude;
  final double longitude;

  Exam.copy(Exam original, {double? newLatitude, double? newLongitude})
      : subject = original.subject,
        date = original.date,
        time = original.time,
        minutes = original.minutes,
        latitude = newLatitude ?? original.latitude,
        longitude = newLongitude ?? original.longitude;


  Exam({
    required this.subject,
    required this.date,
    required this.time,
    required this.minutes,
    required this.latitude,
    required this.longitude,
  }
  );
  String get formattedDate => DateFormat.yMd().format(date);


}
