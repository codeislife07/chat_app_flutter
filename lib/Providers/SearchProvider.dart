import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Firebase/firebaseInstance.dart';
import '../Firebase/notification/NotificationService.dart';
import '../model/UserModel.dart';

class SearchProvider extends ChangeNotifier{
  UserModel? CUser;
  var search=TextEditingController();
  List<UserModel> users=[];
  List<String> recent=[];

  bool local=true;
  SearchProvider(){
    //getfriends();
  }

  void searchUsers() {
    if(search.text.isEmpty){
      local=true;
    }else{
      local=false;
    }
    fbdatabase().search.orderByChild('name').startAt("${search.text}").onValue.listen((event) {
      var data=event.snapshot.value as Map;
      // print(data);
      users.clear();
      List<UserModel> AllUsers=[];
      if(data!=null){
        data.forEach((key, value) {
          print(data[key]);
          UserModel user=fbdatabase().getUserfromJson(data[key])!;
          if(user.uid!=FirebaseAuth.instance.currentUser!.uid.toString()){
            AllUsers.add(user);
          }
        });
        var list=AllUsers.where((element) =>(element.name!.contains(search.text) ||
            (element.name!.toLowerCase()).contains(search.text)));
        for(var j in list){
          users.add(j);
        }
      }
      notifyListeners();
    });
  }

  void getfriends() {
    fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
      var data=event.snapshot.value;
      if(data!=null){
        CUser=fbdatabase().getUserfromJson(data as Map);
        notifyListeners();
      }});
    fbdatabase().friend.onValue.listen((event) {
      var data=event.snapshot.value;
      recent.clear();
      if(data!=null){
        var datas=data as Map;
        datas.forEach((key, value) {
          recent.add(datas[key].toString());
        });
      }
      notifyListeners();
    });
  }




}