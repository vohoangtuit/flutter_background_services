import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:workmanager/workmanager.dart';
import '../main.dart';

const taskName = "vtv_daily_services";
class BackgroundService{
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();
  // 📌 Cấu hình thông báo
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    await _requestNotificationPermission();
    await _initializeNotifications();
    _initWorkManager();
  }

  // 📌 Yêu cầu quyền gửi thông báo (Android 13+)
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _initializeNotifications() async {
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = DarwinInitializationSettings();
    var initSettings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }
  Future<void> executeScheduledFunction()async{
    print("✅ Function chạy mỗi 15 phút!");
    final now = DateTime.now();
    _showNotification("Function chạy mỗi 15 phút!","Chạy lúc :  ${now.hour}:${now.minute}:${now.second}");


    // todo check other function and call show notification
    // if (now.hour == 11 && now.minute == 20) {
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc 12 giờ 20");
    //   // 🛠️ Gọi API, cập nhật DB hoặc thực hiện logic bạn muốn tại đây
    // }
    // else if (now.hour == 13 && now.minute<=25) {
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc 1");
    //   // 🛠️ Gọi API, cập nhật DB hoặc thực hiện logic bạn muốn tại đây
    // }
    // else if (now.hour == 13 && now.minute<=45) {
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc 2");
    //   // 🛠️ Gọi API, cập nhật DB hoặc thực hiện logic bạn muốn tại đây
    // }else if(now.hour == 13 && now.minute <= 50){
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc 3");
    // }
    // else if(now.hour == 14 && now.minute <= 15){
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc 4");
    // }
    // else if(now.hour > 14 ){
    //   BackgroundService().showNotification("Scheduled","Thông báo lúc > 14 giờ");
    // }
  }
  _showNotification(String title,String message)async{
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_notification', 'Daily Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails(presentBadge: true));
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
      payload: ""
    );
  }

  _initWorkManager()async{
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);//todo: callbackDispatcher from main
    ///
    Workmanager().registerPeriodicTask(/// todo: register task
      taskName,
      taskName,
      frequency: Duration(minutes: 15),/// todo : time recall task, minimum 15 minutes
     // frequency: Duration(day: 1),
     // frequency: Duration(hours: 48),
      constraints: Constraints(
        networkType: wm.NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
    );
    if (Platform.isIOS) {
      BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15, // ✅ Chạy mỗi 15 phút (tùy theo hệ thống)
          stopOnTerminate: false,
          enableHeadless: true,
        ),
        backgroundFetchHeadlessTask,
      );
    }
  }

}