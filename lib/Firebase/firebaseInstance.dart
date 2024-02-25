import 'package:chatapp/model/UserModel.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constant/AppString.dart';

class fbdatabase{
  final storageRef = FirebaseStorage.instance.ref("users");
  DatabaseReference database=FirebaseDatabase.instance.ref("Random Chat");
  DatabaseReference fake=FirebaseDatabase.instance.ref("fake");
  DatabaseReference notification=FirebaseDatabase.instance.ref("Random Chat").child("notification");
  DatabaseReference requests=FirebaseDatabase.instance.ref().child("requests");
  DatabaseReference search=FirebaseDatabase.instance.ref("Random Chat").child("Users");
  DatabaseReference friend=FirebaseDatabase.instance.ref("Random Chat").child("Friends");
  DatabaseReference recent=FirebaseDatabase.instance.ref("Random Chat").child("Recents");
  User? auth;
  DatabaseReference getuser=FirebaseDatabase.instance.ref("Random Chat").child("Users");
  DatabaseReference chatroom=FirebaseDatabase.instance.ref("Random Chat").child("Chat");
  fbdatabase(){
    auth=FirebaseAuth.instance.currentUser;
  }
  getUserJson(
      {
      required String name,
    required String image,
    required String bio,
    required String uid,
    required String fcm,
    required int gender,
    required int friends, required String number, required String email, required String birthday,String? device}){
    return {
      "name":name,
      "bio":bio,
      "image":image,
      "uid":uid,
      "fcm":fcm,
      "gender":gender,
      "friends":friends,
      "number":"$number",
      "email":email,
      "birthday":birthday,
      "device":device
    };
  }

  UserModel? getUserfromJson(Map data) {
    return UserModel(data['name'], data["image"], data["bio"], data['uid'], data['fcm'], data['gender'], data['friends'],data['number'],data['email'],data['birthday'],data['device']);
  }

}