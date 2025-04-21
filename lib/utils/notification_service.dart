import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications_example',
);

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

class NotificationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((
      ReceivedNotification receivedNotification,
    ) async {
      await showDialog(
        context: _navigatorKey.currentContext!,
        builder:
            (BuildContext context) => AlertDialog(
              title:
                  receivedNotification.title != null
                      ? Text(receivedNotification.title!)
                      : null,
              content:
                  receivedNotification.body != null
                      ? Text(receivedNotification.body!)
                      : null,
              actions: <Widget>[
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      // ignore: avoid_print
      print(payload);
    });
  }

  Future<void> showNotificationCustomSound(title, message) async {
    AndroidNotificationDetails
    androidNotificationDetails = AndroidNotificationDetails(
      icon: "@drawable/launcher_icon",

      'channel',
      appTitle,
      channelDescription: appTitle,
      //sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(sound: 'slow_spring_board.aiff');
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
        LinuxNotificationDetails(
          sound: AssetsLinuxSound('sound/slow_spring_board.mp3'),
        );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      notificationDetails,
    );
  }

  initLocalNotification(GlobalKey<NavigatorState> navigatorKey) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
          DarwinNotificationCategory(
            'textCategory',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.text(
                'text_1',
                'Action 1',
                buttonTitle: 'Send',
                placeholder: 'Placeholder',
              ),
            ],
          ),
          DarwinNotificationCategory(
            'plainCategory',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Action 1'),
              DarwinNotificationAction.plain(
                'id_2',
                'Action 2 (destructive)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive,
                },
              ),
              DarwinNotificationAction.plain(
                'id_3',
                'Action 3 (foreground)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                'id_4',
                'Action 4 (auth required)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.authenticationRequired,
                },
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ];

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
          defaultActionName: 'Open notification',
          defaultIcon: AssetsLinuxIcon('assets/images/logo.png'),
        );
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == 'id_3') {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _navigatorKey = navigatorKey;

    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
  }
}
