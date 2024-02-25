import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapp/Firebase/notification/NotificationService.dart';
import 'package:chatapp/Providers/AddFriendsProvider.dart';
import 'package:chatapp/Providers/ChatProvider.dart';
import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Providers/LoginProvider.dart';
import 'package:chatapp/Providers/NotifiationProvider.dart';
import 'package:chatapp/Providers/SearchProvider.dart';
import 'package:chatapp/Providers/ThemeProvider.dart';
import 'package:chatapp/Screen/AddFriends.dart';
import 'package:chatapp/Screen/ChatScreen.dart';
import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/LoginScreen.dart';
import 'package:chatapp/Screen/ProfileScreen.dart';
import 'package:chatapp/Screen/SearchScreen.dart';
import 'package:chatapp/Screen/SearchUserSreen.dart';
import 'package:chatapp/Screen/SplashScreen.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:chatapp/lan/InitialBinding.dart';
import 'package:chatapp/lan/StorageService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Screen/EditProfile.dart';
import 'Screen/NotificationScreen.dart';
import 'Screen/chat/chat_screen.dart';
import 'constant/AppColors.dart';
import 'Providers/ProfileProvider.dart';
import 'lan/AppTranslations.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //in this onbackgrondMessage in method
  //this method call when app is in background or app terminated so we need to change somthing with this method
  //so first offall go to method that declare in onbackgroundmessage
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //init
  await initalConfig();
//initalize
  storage=Get.find<StorageService>();
  NotificationService().init();
  await ScreenUtil.ensureScreenSize();
 AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: AppColors.primaryDark,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            ledColor: Colors.white)
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group'),
      ],
      debug: true);
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoginProvider>(create: (_)=>LoginProvider()),
          ChangeNotifierProvider<ProfileProvider>(create: (_)=>ProfileProvider()),
          ChangeNotifierProvider<SearchProvider>(create: (_)=>SearchProvider()),
          ChangeNotifierProvider<NotificationProvider>(create: (_)=>NotificationProvider()),
          ChangeNotifierProvider<HomeProvider>(create: (_)=>HomeProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (_)=>ThemeProvider()),
          ChangeNotifierProvider<AddFriendsProvider>(create: (_)=>AddFriendsProvider()),
        ],

        child:  MyApp(),
      )

      );
}

initalConfig()async {
  await Get.putAsync(() => StorageService().init());
}
var storage;
class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> appnavKey=GlobalKey<NavigatorState>();
   MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      navigatorKey: appnavKey,
      title: '${AppString.appname}',
      translations: AppTranslations(),
      locale: storage.lanCode!=null
          ?Locale(storage.lanCode!,storage.countryCode)
          :Locale("en","US"),
      fallbackLocale:Locale("en","US"),
      initialBinding: InitialBinding(),
      theme: ThemeData(
        useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              primary: AppColors.primaryDark,
              seedColor: AppColors.primary),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryDark,
            iconTheme: IconThemeData(
              color: Colors.white
            ),
            titleTextStyle: TextStyle(color: Colors.white,fontSize: 20)
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(AppColors.primaryDark),
            foregroundColor: MaterialStatePropertyAll(Colors.white),
          )
      ),
          //primaryColor: AppColors.primary,
          primarySwatch:MaterialColor(0xFF082480, AppColors.color),
          fontFamily: "okra"
      ),
      initialRoute: AppString.splashScreen,
      routes: {
        AppString.chatScreen: (context) =>  ChatScreen(),
        AppString.homeScreen: (context) =>  HomeScreen(),
        AppString.loginScreen: (context) =>  LoginScreen(),
        AppString.splashScreen: (context) =>  SplashScreen(),
        AppString.notification: (context) =>  NotifiationScreen(),
        AppString.searchScreen: (context) =>  SearchScreen(),
        AppString.searchUserScreen: (context) =>  SearchUserScreen(),
        AppString.editProfile: (context) =>  EditProfile(),
      },
      debugShowCheckedModeBanner: false,
     // home: SplashScreen(),
    );
  }
}


//add this line to recive notification when app terminated or in background in release mode
@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp();
  print("app bg nptification");
  NotificationService().showNotification(message, false,custom: false,);
}

