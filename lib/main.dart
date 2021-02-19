import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:papucon/model/model.dart';
import 'package:provider/provider.dart';
import 'package:papucon/pages/splash_page.dart';
import 'package:papucon/stores/login_store.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rxdart/subjects.dart';

import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

final platform = const MethodChannel('com.tapick.chat/cn1');
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
//다운로더 초기화
  await FlutterDownloader.initialize(debug: true);

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('ko', 'KR'), Locale('ja', 'JP')],
        path: 'assets/translations',
        //fallbackLocale: Locale('ja', 'JP'),
        child: App()),
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    final methodChannel = MethodChannel("com.tapick.chat/cn1");
    methodChannel.setMethodCallHandler(didRecieveTranscript);
    //checkForUpdate();

    platform.invokeMethod('clear', "");
    super.initState();
  }

  Future<void> didRecieveTranscript(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    final String utterance = call.arguments;
    switch (call.method) {
      case "didRecieveTranscript":
        /* print("KDS Run : " + utterance.toString()); */
        await platform.invokeMethod('stream', utterance);
    }
  }

  void _showError(dynamic exception) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MultiProvider(
      providers: [
        Provider<LoginStore>(
          create: (_) => LoginStore(),
        ),
        ChangeNotifierProvider(
          create: (_) => nowProfile(),
        ),
        ChangeNotifierProvider(
          create: (_) => storeUID(),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GetMaterialApp(
          //Get dev https://pub.dev/packages/get
          // navigatorKey: NavigationService().navigatorKey,
          debugShowCheckedModeBanner: true, //Debug I
          navigatorObservers: <NavigatorObserver>[observer],
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: Color(0xFFD0393e),
          ),
          initialRoute: '/',
          home: SplashPage(),
        ),
      ),
    );
  }
}
