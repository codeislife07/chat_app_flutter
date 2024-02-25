import 'dart:convert';

import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Firebase/notification/NotificationService.dart';
import '../constant/AppString.dart';
import '../model/NotifiationModel.dart';
import '../model/RequestsModel.dart';

class NotificationProvider extends ChangeNotifier{
  UserModel? CUser;
  List<NotificationModel> noModel=[];
  List<RequestsModel> reModel=[];
  Map<String,UserModel> noUser={};

  NotificationProvider(){
    findData();
  }

  void findData() async{
    var usersDAtas=await fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).get();

      if(usersDAtas.value!=null){
        CUser=fbdatabase().getUserfromJson(usersDAtas.value as Map);
        notifyListeners();
        fbdatabase().notification.child(CUser!.uid!).onValue.listen((event) async {
          print("notification");
          noModel.clear();
          noUser.clear();
          var data=event.snapshot.value ?? null;
          if(data!=null){
            // print(data);
            (data as Map).forEach((key, value) {
              // print(data[key]);
              noModel.add(notificationModelFromJson(jsonEncode(data[key])));
            });
          }
          noModel.sort((a,b)=>b.time.compareTo(a.time));
          for(var i in noModel){
            var datas=(await fbdatabase().search.child(i.uid).get()).value as Map;

              if(datas!=null){
                var u=fbdatabase().getUserfromJson(datas as Map);
                noUser["${u!.uid!}"]=fbdatabase().getUserfromJson(datas as Map)!;
              }
              notifyListeners();
          }
          // noModel=notificationModelFromJson(jsonEncode(data));
          notifyListeners();
        });
      }}
    notifyListeners();


  void removeNotification(NotificationModel modelINdex, int index) async{
    noModel.clear();
    noUser.clear();
    await  fbdatabase().notification.child(CUser!.uid!).child(modelINdex.uid).remove();
    // noModel.removeAt(index);
    // noUser.removeAt(index);
    findData();
    notifyListeners();
  }

  void acceptRequest(NotificationModel noItem, UserModel noUsers) {
    // Navigator.pop(MyApp.appnavKey.currentContext!);
    noModel.clear();
    noUser.clear();
    notifyListeners();
    var time=DateTime.now().microsecondsSinceEpoch.toString();
    var notifocationReciver=NotificationModel(status: 1, msg: " accepted your friend request", uid: CUser!.uid!, time: time);
    fbdatabase().friend.child(CUser!.uid!).child(noItem.uid).set({'uid':noItem.uid});
    fbdatabase().friend.child(noItem.uid).child(CUser!.uid!).set({'uid':CUser!.uid!});
    var sender=NotificationModel(status: 1, msg: " and you friends now", uid: noItem!.uid!, time: time);
    fbdatabase().notification.child(noItem.uid).child(CUser!.uid!).update(
        {
          "status":1,
          "msg":notifocationReciver.msg,
          "uid":notifocationReciver.uid,
          "time":notifocationReciver.time,
        }
    );
    fbdatabase().notification.child(CUser!.uid!).child(noItem.uid).update(
      {
        "status":1,
        "msg":sender.msg,
        "uid":sender.uid,
        "time":sender.time,
      }
    );
    // fbdatabase().notification.child(CUser!.uid!).child(noUsers.uid!).remove();
    // fbdatabase().notification.child(noUsers.uid!).child(CUser!.uid!).remove();
    NotificationService().sendNotifiation(to: noUsers.fcm!,
        otherParamters:{
          "title":"${CUser!.name}",
          "body":"${CUser!.name} accepted your friend request",
          'user':"${CUser!.uid}",
          "image":CUser!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":CUser!.image!,
          "action":"notification"
        }
    );
    findData();
    // Navigator.pushReplacementNamed(MyApp.appnavKey.currentContext!, AppString.notification);
  }
}