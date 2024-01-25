import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab3/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AwesomeNotifications().initialize(
      null,
      [NotificationChannel(
          channelGroupKey: "basic_channel_group",
          channelKey: "basic_channel",
          channelName: "Basic Notification",
          channelDescription: "Basic notification channel")
      ],
      channelGroups: [
        NotificationChannelGroup(channelGroupKey: "basic_channel_group",
            channelGroupName: "Basic Group")
      ]
  );
  bool isNotificationAllowed = await AwesomeNotifications().isNotificationAllowed();
  if(!isNotificationAllowed){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }else {
    print("Notification permission is already granted.");
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const WidgetTree(),
    );
    }
  }