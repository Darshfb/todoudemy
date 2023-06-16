import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String selectedNotificationPayload = '';

  // final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

  initializeNotification() async {
    tz.initializeTimeZones();
    // _configureSelectNotificationSubject();
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    // final StreamController<String?> selectNotificationStream =
    //     StreamController<String?>.broadcast();
    // const String navigationActionId = 'id_3';
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     // selectNotificationStream.add(notificationResponse.payload);
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     if (notificationResponse.actionId == navigationActionId) {
        //       // selectNotificationStream.add(notificationResponse.payload);
        //     }
        //     break;
        // }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // await flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: (NotificationResponse? payload) {
    //     if (payload!.payload != null) {
    //       debugPrint('notification payload: ${payload.payload}');
    //     }
    //     selectNotificationSubject.add(payload.payload.toString());
    //   },
    //   onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    // );
  }

  displayNotification({required String title, required String body}) async {
    print('doing test');
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ));
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  scheduledNotification({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minutes,
    required String title,
    required String des,
    required int id,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      des,
      _nextInstanceOfTenAM(
          year: year, month: month, day: day, hour: hour, minutes: minutes),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your other channel id',
          'your other channel name',
          channelDescription: 'your other channel description',
          sound: RawResourceAndroidNotificationSound('slow_spring_board'),
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    //  payload: '$title | $des | $day |',
    );
  }

  tz.TZDateTime _nextInstanceOfTenAM(
      {required int year,
      required int month,
      required int day,
      required int hour,
      required int minutes}) {
    print("$year  $month  $day");
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
    return scheduledDate;
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    /* showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Title'),
        content: const Text('Body'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
    );
 */
  }

  // void _configureSelectNotificationSubject() {
  //   selectNotificationSubject.stream.listen((String payload) async {
  //     debugPrint('My payload is $payload');
  //     // await Get.to(() => NotificationScreen(payload));
  //   });
  // }
}
