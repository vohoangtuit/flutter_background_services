import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_servies/screens/home_screen.dart' show HomeScreen;
import 'package:flutter_background_servies/services/background_service.dart' show BackgroundService, taskName;
import 'package:workmanager/workmanager.dart' as wm;
import 'package:workmanager/workmanager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background service',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen() ,
    );
  }
}

// 📌 WorkManager chạy nền
@pragma('vm:entry-point')
void callbackDispatcher() { /// should set here
  Workmanager().executeTask((task, inputData) async {
    print("✅ task ${task.toString()}");
    if (task == taskName) {
      BackgroundService().executeScheduledFunction();
    }
    return Future.value(true);
  });
}



// - export PATH="/Users/vohoangtuit/DATA/DEVELOP/AndroidStudio/flutter_sdk/flutter/bin:$PATH" // change path
//   - export PATH="/Users/admin/VO_HOANG_TU/dev/AndroidStudio/sdk/flutter/bin:$PATH"
//
//
// todo update file pub
// > flutter clean
// > flutter pub get
// > cd ios
// > pod update || pod install // todo if error run:  'pod deintegrate' before
//
// // flutter doctor
//  flutter run --release