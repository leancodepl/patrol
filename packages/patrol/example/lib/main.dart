import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patrol_challenge/cubit/auth_cubit.dart';
import 'package:patrol_challenge/firebase_options.dart';
import 'package:patrol_challenge/handlers/notification_handler.dart';
import 'package:patrol_challenge/pages/home_page.dart';
import 'package:patrol_challenge/pages/push_notification/notification_success_page.dart';
import 'package:patrol_challenge/ui/style/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  debugPrint('!Google sign in will not work when dev flavor used!');

  runApp(const MyApp());
}

Future<void> initApp() async {
  _setUpTheme();
  await _initFirebase();
  await _askForLocationPermission();
}

void _setUpTheme() {
  final mySystemTheme = SystemUiOverlayStyle.light
      .copyWith(systemNavigationBarColor: PTColors.lcBlack);

  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> _askForLocationPermission() => Geolocator.requestPermission();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit()..init(),
      child: Provider(
        lazy: false,
        create: (_) => NotificationHandler(
          FlutterLocalNotificationsPlugin(),
          FirebaseMessaging.instance,
        )..init(() => Navigator.push(context, notificationRoute)),
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                  transitionType: SharedAxisTransitionType.horizontal,
                ),
                TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                  transitionType: SharedAxisTransitionType.horizontal,
                ),
              },
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey),
            primaryColor: PTColors.lcBlack,
            canvasColor: PTColors.textDark,
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: PTColors.lcYellow.withOpacity(0.5),
              cursorColor: PTColors.textWhite,
              selectionHandleColor: PTColors.lcYellow,
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Patrol Challenge',
          home: const HomePage(),
        ),
      ),
    );
  }
}
