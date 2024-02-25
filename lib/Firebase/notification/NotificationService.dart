import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Providers/ChatProvider.dart';
import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Screen/ChatScreen.dart';
import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/MainScreen.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../function/MyFunction.dart';
import '../../main.dart';
import '../../util/Shared_Preference.dart';

class NotificationService{
  late final Uuid _uuid;
  String? _currentUuid;
  init()async{
    _uuid = Uuid();
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    var settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((value){
    if(value!=null){
      showNotification(value,true,custom:false);
    }
    });

    FirebaseMessaging.instance.getToken().then((value) {
      String? token = value;
      Shared_Preferences.prefSetString("fcm", value!);
      print("Token====$token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        AppleNotification? apple = message.notification?.apple;
        print("Notifiation");
          if(message.data!=null) {
            showNotification(message,false,custom: true);
          }

      });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        print("Notifiation");
        if(message.data!=null){
          showNotification(message,false,custom: true,);
        }
      });

    }

  showNotification(RemoteMessage value, bool bool, {required bool  custom,}) async {
    var screen='';
    var hidenotifiction=false;
    print(value.data);
    var arg={};
    switch(value.data['action']){
      case "chat":
        print("Chat number ");
        screen=AppString.chatScreen;
        arg['user']=value.data['user'];
        if(MyApp.appnavKey.currentContext!=null){
          var routes=Get.currentRoute;
          print("routesName");
          print(routes!);
          if(routes!=null){
            print(routes);
            if(routes==AppString.chatScreen){
               if(await Shared_Preferences.prefGetString("reciver", "")==value.data['user']){
                 return;
             }
            }
          }

        }
        var chatNumber=await Shared_Preferences.prefGetInt(value.data['user'], 0)??0;
        print("Chat number ${chatNumber++}");
        Shared_Preferences.prefSetInt(value.data['user'], chatNumber);
        await fbdatabase().database.child("recent").child(FirebaseAuth.instance.currentUser!.uid).child(value.data['user']).update({'number':chatNumber});
        print("Chat number $chatNumber");
        break;
      case "notification":
        screen=AppString.searchUserScreen;
        var d=(await Shared_Preferences.prefGetInt("notifications", 0)??0);
        Shared_Preferences.prefSetInt("notifications", d++);
        // print(d);
        arg['user']=value.data['user'];
        if(MyApp.appnavKey.currentContext!=null){
          var routes=Get.currentRoute;
          // print("routesName");
          //print(routes!.settings.name);
          if(routes!=null){
            // print(routes);
            if(routes==AppString.notification){
             return;
            }
          }
        }
        break;
    }

    if(custom){
      CherryToast.warning(
        displayIcon: true,
          toastDuration:Duration(seconds: 3),
        title:  Text( value.data['title']),
        action:  Text( value.data['body'],style: TextStyle(overflow: TextOverflow.ellipsis),maxLines: 2,),
        actionHandler: (){
          // print("notification tap");
        },
      ).show(MyApp.appnavKey.currentContext!);
    }else{
      if(bool){
       // Navigator.pushAndRemoveUntil(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>MainScreen()  ), (route) => false);
        Navigator.pushNamed(MyApp.appnavKey.currentContext!,(screen),arguments: arg);
      }else{
        var paload=value.data.map((key, value)=>MapEntry(key, value.toString()));
        paload['screen']=screen;
        paload['arg']=jsonEncode(arg);
        AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: -1,
              channelKey: 'basic_channel',
              title: value.data['title'],
              body: value.data['body'],
              showWhen: true,
              // icon: "",
              largeIcon: value.data['image'],
              payload: paload,
              // notificationLayout: NotificationLayout.Messaging,
              category: NotificationCategory.Message,
              displayOnForeground: true,
              displayOnBackground: true,
            ));
      }

    }
    if(value.data['action']=="logout"){
      print("logout");
      Shared_Preferences.prefSetBool(AppString.loginkey, false);
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      logout();
    }

    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );

  }

  sendNotifiation({
    required String to,
    required  Map<String, String>? otherParamters})async{

    var header={
      "Authorization": "key=AAAA-MPw3U4:APA91bGN4zYyN7D53TMAqPW89I7sVim2LOK8QJysRCIRMCWuazSmlUQLSKaBvxUtNXIbqaHuQqOppF_CF0SmxMB6aML-ABPDiAbz5GxVDg2v4HSmjuNODRcnVlVNttHqEk4039HUCyn5",
      "Content-Type": "application/json"
    };
    Map<String,dynamic> body= {
      "to" : "$to",
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "priority":"high",
      "notification" : {
      },
      "data" :otherParamters
    };


    var dta=await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send")
        ,headers: header,body: jsonEncode(body)
    );
    print("Resposne ${dta.body}");

  }

}
class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    if(receivedAction.payload!=null){
      Navigator.pushNamed(MyApp.appnavKey.currentContext!, receivedAction.payload!['screen']!,arguments: jsonDecode(receivedAction.payload!['arg']!));
    }
  }

}