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
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    await _requestNotificationPermission();
    await _initializeNotifications();


    // ✅ Khởi tạo WorkManager (Android) & Background Fetch (iOS)
    if (Platform.isAndroid) {
      await _initWorkManager();
    } else if (Platform.isIOS) {
      await _initBackgroundFetch();
    }
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
    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }
  Future<void> executeScheduledFunction()async{
    print("✅ Function chạy mỗi 15 phút!");
    final now = DateTime.now();
    final lastRun = DateTime(2025, 2, 27); // ✅ Thay bằng ngày chạy lần trước
    final difference = now.difference(lastRun).inDays;
    print("✅ difference $difference");
    _showNotification("Function chạy mỗi giờ","Chạy lúc :  ${now.hour}:${now.minute}:${now.second}");
    // if (difference % 2 == 0) { // ✅ Kiểm tra nếu đã đủ 2 ngày
    //   print("✅ Chạy function sau mỗi 2 ngày!");
    //   _showNotification("Function chạy mỗi 2 ngày ","Chạy lúc :  ${now.hour}:${now.minute}:${now.second}");
    //   // 🛠️ Gọi API, cập nhật DB hoặc thực hiện logic nền tại đây
    // } else {
    //  // print("⏳ Chưa tới ngày chạy...");
    //   _showNotification("Đã qua ","$difference ngày");
    // }

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
      'vietravel', 'Daily Vietravel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails(presentBadge: true));
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
      payload: ""
    );
  }


  // 📌 Khởi tạo WorkManager để chạy mỗi 2 ngày (Android)
  _initWorkManager()async{
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);//todo: callbackDispatcher from main
    ///
    Workmanager().registerPeriodicTask(/// todo: register task
      taskName,
      taskName,
     // frequency: Duration(minutes: 15),/// todo : time recall task, minimum 15 minutes
      //frequency: Duration(days:2),// ✅ 2 mỗi 2 ngày
      frequency: Duration(minutes:60),// ✅
     // frequency: Duration(hours: 48),
      constraints: Constraints(
        networkType: wm.NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
    );

  }
// 📌 Khởi tạo Background Fetch để chạy nền trên iOS (không đảm bảo 3 ngày)
  Future<void> _initBackgroundFetch() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // ✅ iOS không hỗ trợ đặt chính xác 24h
        stopOnTerminate: false, // ✅ Tiếp tục chạy ngay cả khi app bị đóng
        enableHeadless: true, // ✅ Chạy ngay cả khi app không mở UI
        requiresBatteryNotLow: false,
        //requiresNetworkConnectivity: false,
      ),
          (String taskId) async {
        await executeScheduledFunction();
        BackgroundFetch.finish(taskId);
      },
    );
  }
}