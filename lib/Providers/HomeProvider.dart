import 'dart:convert';
import 'dart:io';

import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Firebase/notification/NotificationService.dart';
import 'package:chatapp/Providers/ProfileProvider.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:chatapp/function/MyFunction.dart';
import 'package:chatapp/model/ChatModel.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import '../main.dart';
import '../model/UserModel.dart';

class HomeProvider extends ChangeNotifier {
  List<UserModel> users = [];
  UserModel? CUser;
  Map<String, UserModel> values = {};
  List<ChatModel> chats = [];
  String notifications = "0";
  bool loading = true;

  HomeProvider() {
    // showLoader();
    assignData();
    Provider.of<ProfileProvider>(MyApp.appnavKey.currentContext!,listen: false);
    //datachangeNumberChat();
  }


  void assignData() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final deviceInf = await deviceInfo.deviceInfo;
    final allInfo = deviceInf.data;
    // print("device data ${allInfo.entries}");
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    String? deviceId = await _getId();
    var fcm = await Shared_Preferences.prefGetString("fcm", "");
    var time=DateTime.now().microsecondsSinceEpoch.toString();
    var notifications = (await Shared_Preferences.prefGetInt(
        "notifications", 0) ?? 0).toString();
    var dataUser =await fbdatabase().getuser.child(
        FirebaseAuth.instance.currentUser!.uid).get();
    if (dataUser != null && dataUser.value!=null) {
      CUser = fbdatabase().getUserfromJson(dataUser.value as Map)!;
      if(CUser!.fcm!=fcm){
        fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).update(
            {'fcm': fcm});
        if(CUser!.device!=androidInfo.model && (dataUser.value as Map)['deviceid']!=deviceId){
          NotificationService().sendNotifiation(to: CUser!.fcm!,
              otherParamters:{
                "title":"Log Out",
                "body":"Recently login in another device",
                "action":"logout"
              }
          );
          fbdatabase().notification.child(CUser!.uid!).child(time).update(
              {
                "status":2,
                "msg":"Recently login in ${androidInfo.model}",
                "uid":CUser!.uid,
                "time":time,
              }
          );
          fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).update(
              {'fcm': fcm,'device':androidInfo.model,"deviceid":deviceId});
        }
      }

    } else {
      var user = fbdatabase().getUserJson(
          name: FirebaseAuth.instance.currentUser!.displayName ??
              "User${FirebaseAuth.instance.currentUser!.uid.toString()
                  .substring(0, 5)}",
          image: FirebaseAuth.instance.currentUser!.photoURL ?? "",
          bio: "",
          uid: "${FirebaseAuth.instance.currentUser!.uid}",
          fcm: fcm!,
          gender: 1,
          friends: 0,
          number: FirebaseAuth.instance.currentUser!.phoneNumber ?? "",
          email: FirebaseAuth.instance.currentUser!.email ?? "",
          birthday: "",device: androidInfo.model);
      fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).set(
          user);
    }

    fbdatabase().database.child("recent").child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
      var data=event.snapshot.value;
      // print("recent list");
      // print(data);
      chats.clear();
      users.clear();
      if(data!=null){
        var datas=data as Map;
        datas.forEach((key, value) {
          // print(datas[key]);
          chats.add(ChatModel(data[key]['msg']==null?"":data[key]['msg'].runtimeType!=(List<Object?>)?data[key]['msg']:utf8.decode((data[key]['msg'].cast<int>())), data[key]['sender'], data[key]['reciver'],DateTime.parse(data[key]['time']??DateTime.now().toString()),data[key]['number']));
          notifyListeners();
        });
          }else{
        loading=false;
        notifyListeners();
        // print(loading);
      }

      chats.sort((a,b)=>b.time!.compareTo(a.time!));
      // users.clear();
      for(var i in chats){
        fbdatabase().database.child("Users").child(i.reciver==FirebaseAuth.instance.currentUser!.uid?i.sender!:i.reciver!).onValue.listen((event)  {
          var data=event.snapshot.value as Map;
          if(data!=null){
            var user=fbdatabase().getUserfromJson(data)!;
              values[user.uid!]=(user);
          }
          // print(values);
          notifyListeners();
        });
      }
    notifyListeners();
    });
  notifyListeners();
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }
  // void datachangeNumberChat() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     AppleNotification? apple = message.notification?.apple;
  //     print("Notifiation");
  //     if(message.data!=null) {
  //       var routes=Get.currentRoute;
  //       print("routesName");
  //       //print(routes!.settings.name);
  //       if(routes!=null){
  //         print(routes);
  //         if(routes==AppString.chatScreen){
  //           if(await Shared_Preferences.prefGetString("reciver", "")==message.data['user']){
  //             return;
  //           }
  //         }
  //       }
  //       updateIndexOfChat(message.data['user']);
  //     }
  //   });
  //   loading=false;
  //   notifyListeners();
  // }

}
