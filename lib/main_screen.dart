import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_practice/new_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? mtoken = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState() {
    super.initState();

    requestPermission();
    getToken();
    initInfo();
  }

  initInfo() {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      try {
        if (notificationResponse.payload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return NewPage(
                  info: payload.toString(),
                );
              },
            ),
          );
          debugPrint('notification payload: $payload');
        } else {}
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('......................onMessage......................');
      print(
          'onMessage: ${message.notification?.title}/${message.notification?.body}}');

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'dbfood', 'dbfood',
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
        //sound: RawResourceAndroidNotificationSound('notification')
      );

      NotificationDetails platformChannelSpesifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpesifics,
          payload: message.data['body']);
    });

    //  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    //   final String? payload = notificationResponse.payload;
    //   if (notificationResponse.payload != null) {
    //     debugPrint('notification payload: $payload');
    //   }
    //   await Navigator.push(
    //     context,
    //     MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    //   );
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("My token is $mtoken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection('UserTokens').doc('user2').set({
      'token': token,
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAgMkjIQM:APA91bEH_uB6kxkZijyjzpdE16Qr2qIfvRFuthOWtPWg1ShXJGSB51k4FmNKiZL3I_iF_pk-sIYcZsUcb14afiIp6kV1zrNZXDsYulISwqQtzD6NlZBlfEvSv0ehfg0vsUUYbyaHWiFR'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'dbfood',
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notifications");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Firebase Messaging Notification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),textAlign: TextAlign.center,),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Username (Hanya: user1)",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: username,
              ),
               const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Title Notification",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: title,
              ),
               const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Body Notification",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: body,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  String name = username.text.trim();
                  String titleText = title.text;
                  String bodyText = body.text;

                  if (name != "") {
                    DocumentSnapshot snap = await FirebaseFirestore.instance
                        .collection('UserTokens')
                        .doc(name)
                        .get();

                    String token = snap['token'];
                    print(token);

                    sendPushMessage(token, bodyText, titleText);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.lightBlueAccent.withOpacity(0.8)),
                      ]),
                  child: const Center(
                    child: Text('Berikan Notif', style: TextStyle(color: Colors.white),),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
