import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gender_picker/source/enums.dart';

import '../Firebase/firebaseInstance.dart';

class AddFriendsProvider extends ChangeNotifier{

  UserModel? user;
  List<UserModel> users=[];
  int genderIndex=1;
  AddFriendsProvider(){
    assignData();
  }

  Future<void> assignData() async {
    var datas=await fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).get();
      user = fbdatabase().getUserfromJson(datas.value as Map);
    var data=(await fbdatabase().getuser.limitToFirst(50).get()).value as Map;
      // print(data);
      data.forEach((key, value) {
        if(data[key]!=FirebaseAuth.instance.currentUser!.uid!){
          users.add(fbdatabase().getUserfromJson(data[key])!);
        }
      });

    notifyListeners();
  }
  void changegender(Gender gender) {
    genderIndex=gender.index+1;
    notifyListeners();
  }

}