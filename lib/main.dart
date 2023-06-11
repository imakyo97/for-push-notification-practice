import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:for_push_notification_practice/firebase_options.dart';

// バックグラウンドで通知を受け取った時のハンドラー
// トップレベルに書く必要がある
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("😍Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('🎉: ${fcmToken}');

  // Push通知の許可をリクエストする
  // レスポンスでユーザーが許可したか確認できる
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // [iOS]フォアグラウンドでもバナーを表示できるようにする
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Push通知をフォアグラウンドで受け取ったとき
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('😄Got a message whilst in the foreground!');
    print('😄Message data: ${message.data}');

    if (message.notification != null) {
      print('😄Message also contained a notification: ${message.notification}');
    }
  });

  // Push通知をバックグラウンドで受け取ったとき
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // バナータップでバックグラウンドからフォアグラウンドに移動したとき
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      print('😎onMessageOpenedAppが呼ばれた');
    },
  );

  // バナータップでアプリを終了状態から開いたとき
  FirebaseMessaging.instance.getInitialMessage().then(
    (value) {
      print('😡getInitialMessageが呼ばれた');
    },
  ).onError(
    (error, stackTrace) {
      print('😡getInitialMessageが呼ばれた');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
