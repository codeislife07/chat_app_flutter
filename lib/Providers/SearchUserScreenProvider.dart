import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebaseInstance.dart';
import '../Firebase/notification/NotificationService.dart';
import '../model/NotifiationModel.dart';

class SearchUserScreenProvider extends ChangeNotifier{
  UserModel? user;
  int? status;
  UserModel? CUser;

  SearchUserScreenProvider(reciver){
    assignData(reciver);
  }
  void assignData(reciver) async{

    fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
      CUser=fbdatabase().getUserfromJson(event.snapshot.value as Map);
      var data=event.snapshot.value as Map;
      notifyListeners();
    });


    fbdatabase().search.child(reciver).onValue.listen((event) {
      user=fbdatabase().getUserfromJson(event.snapshot.value as Map);
      print(event.snapshot.value);
      fbdatabase().notification.child(FirebaseAuth.instance.currentUser!.uid).child(user!.uid!).onValue.listen((event) {
        var data=event.snapshot.value;
        if(data!=null){
          var datas=data as Map;
          status=datas['status'];
        }notifyListeners();
      });
      notifyListeners();
    });

      fbdatabase().notification.child(reciver).child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
        var data=event.snapshot.value;
        if(data!=null){
          var datas=data as Map;
          if(datas['status']==0){
            status=2;
          }
        }
        notifyListeners();
      });
      notifyListeners();

  }

  void sendrequest() {
    var time=DateTime.now().microsecondsSinceEpoch.toString();
    fbdatabase().notification.child(user!.uid!).child(CUser!.uid!).set({
      "uid":FirebaseAuth.instance.currentUser!.uid,
      "msg":" sent you a friend requests",
      "time":"${time}",
      "status":0
    });
    NotificationService().sendNotifiation(to: user!.fcm!,
        otherParamters:{
          "title":"${CUser!.name}",
          "body":"${CUser!.name} sent you a friend requests",
          'user':"${CUser!.uid}",
          "image":CUser!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":CUser!.image!,
          "action":"notification"
        }
    );
    status=0;
    notifyListeners();

  }

  void rejectRequest() async{
    await  fbdatabase().notification.child(CUser!.uid!).child(user!.uid!).remove();
    status=null;
    notifyListeners();
  }

  void acceptRequest() {
    var time=DateTime.now().microsecondsSinceEpoch.toString();
    var notifocationReciver=NotificationModel(status: 1, msg: " accepted your friend request", uid: CUser!.uid!, time: time);
    fbdatabase().friend.child(CUser!.uid!).child(user!.uid!).set({'uid':user!.uid});
    fbdatabase().friend.child(user!.uid!).child(CUser!.uid!).set({'uid':CUser!.uid!});
    var sender=NotificationModel(status: 1, msg: " and you friends now", uid: user!.uid!, time: time);
    fbdatabase().notification.child(user!.uid!).child(CUser!.uid!).update(
        {
          "status":1,
          "msg":notifocationReciver.msg,
          "uid":notifocationReciver.uid,
          "time":notifocationReciver.time,
        }
    );
    fbdatabase().notification.child(CUser!.uid!).child(user!.uid!).update(
        {
          "status":1,
          "msg":sender.msg,
          "uid":sender.uid,
          "time":sender.time,
        }
    );
    // fbdatabase().notification.child(CUser!.uid!).child(noUsers.uid!).remove();
    // fbdatabase().notification.child(noUsers.uid!).child(CUser!.uid!).remove();
    NotificationService().sendNotifiation(to: user!.fcm!,
        otherParamters:{
          "title":"${CUser!.name}",
          "body":"${CUser!.name} accepted your friend request",
          'user':"${CUser!.uid}",
          "image":CUser!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":CUser!.image!,
          "action":"notification"
        }
    );
    notifyListeners();
  }
}