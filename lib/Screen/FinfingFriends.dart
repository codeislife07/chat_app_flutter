import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebaseInstance.dart';
import '../constant/AppColors.dart';

class FindingFriends extends StatefulWidget{
  UserModel user;
  List<UserModel> users;
  FindingFriends(this.user, this.users);

  @override
  State<StatefulWidget> createState()=>FindingFriendsState();

}

class FindingFriendsState extends State<FindingFriends> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkusers();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: AvatarGlow(
        glowColor: AppColors.primary,
        endRadius: 100.0,
        duration: Duration(milliseconds: 1000),
        repeat: true,
        showTwoGlows: true,
        repeatPauseDuration: Duration(milliseconds: 0),
        child: Container(
          height: 100,width: 100,
          child: Material(// Replace this child with your own
            elevation: 8.0,
            shape: CircleBorder(),
            child: (widget.user?.image??"").isEmpty?CircleAvatar(
              backgroundImage: AssetImage(
                "assets/images/ic_logo.png",
              ),
            ):CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                widget.user!.image!,
              ),
              radius: 40.0,
            ),
          ),
        ),
      ),
    ),
  );
  }

  @override
  void dispose() {
    fbdatabase().database.child("search").child(FirebaseAuth.instance.currentUser!.uid).remove();
  super.dispose();
  }

  void checkusers() {
    print("Searching....");
    fbdatabase().database.child("randomchat").child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
      var data=event.snapshot.value;
      if(data!=null){
        var datas=data as Map;
        fbdatabase().database.child("search").child(FirebaseAuth.instance.currentUser!.uid).remove();
        fbdatabase().database.child("search").child(datas['id']).remove();
        Navigator.pushReplacementNamed(context, AppString.chatScreen,arguments: {"user":datas['id']});
      }
    });

    fbdatabase().database.child("search").onValue.listen((event) {
      var data=event.snapshot.value;
      //print(data);
      if(data!=null){
        var datas=data as Map;
        datas.forEach((key, value) {
          var dat=datas[key];
          print("Single DAta ${datas[key]}");
          if(dat['id']==FirebaseAuth.instance.currentUser!.uid){
          }else{
            fbdatabase().database.child("search").child(FirebaseAuth.instance.currentUser!.uid).remove();
            fbdatabase().database.child("search").child(dat['id']).remove();
            fbdatabase().database.child("randomchat").child(dat['id']).set({
              'uid':FirebaseAuth.instance.currentUser!.uid
            });
            Navigator.pushReplacementNamed(context, AppString.chatScreen,arguments: {"user":dat['id']});
          }
        });

      }else{
      }
    });
    Future.delayed(Duration(seconds: 15),(){
      fbdatabase().fake.onValue.listen((event) {
        var data=event.snapshot.value as Map;
        if(data['fake']==true){
          final _random = new Random();
          var element = widget.users[_random.nextInt(widget.users.length)];
          fbdatabase().database.child("search").child(FirebaseAuth.instance.currentUser!.uid).remove();
          //fbdatabase().database.child("search").child(dat['id']).remove();
          Navigator.pushReplacementNamed(context, AppString.chatScreen,arguments: {"user":element.uid});
        }
      });
    });
  }

}