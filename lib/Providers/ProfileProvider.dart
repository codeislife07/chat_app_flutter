import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Screen/EditProfile.dart';
import 'package:chatapp/function/MyFunction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../model/UserModel.dart';
import '../util/Shared_Preference.dart';

class ProfileProvider extends ChangeNotifier{

  UserModel? user;


  int percentage=0;

  XFile? file;
  var name=TextEditingController();
  var number=TextEditingController();
  var email=TextEditingController();
  var birthday=TextEditingController();
  int gender=0;
  var coutry={"name": "India", "countryCode": "IN", "phoneCode": "+91"};
  var bio=TextEditingController();

  PackageInfo? packageInfo;
  ProfileProvider(){
    assignData();
  }

  void assignData() async{
    packageInfo = await PackageInfo.fromPlatform();
      fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {

        user=fbdatabase().getUserfromJson(event.snapshot.value as Map);
        var data=event.snapshot.value as Map;
        var inValue=0;
        data.forEach((key, value) {
          if(data[key]!=""){
            inValue++;
          }
        });
        percentage=inValue;
        name.text=user!.name!;
        bio.text=user!.bio!;
        email.text=user!.email!;
        birthday.text=user!.birthday!;
        gender=user!.gender!;
        number.text=user!.number==""?"":user!.number!.substring(3,user!.number!.length);
        coutry['phoneCode']=user!.number==""?"+91":user!.number!.substring(0,3);
        notifyListeners();
      });
  }

  void logout() async{
    user=null;
    notifyListeners();
  }

  void SelectImage() async{
    var status=await Permission.storage.request();
    // if(status==PermissionStatus.granted){
      XFile? image=await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image!=null){
        final storageRef = FirebaseStorage.instance.ref();

        final storage = storageRef.child("${user!.uid}");
        await storage.putFile(File(image!.path  )).then((p0){
          print(p0);
        });
        // await FirebaseDatabase.instance.ref("chatking").child("Users").child(user!.uid).update(data);

      }
    // }else{
    //   DangerAlertBox(context: MyApp.appnavKey.currentContext,
    //       title: "Need storage permission".tr,
    //       messageText: "",
    //       buttonText: "Close".tr
    //   );
    //   AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
    // }

  }

  void changePhoto(EditProfileState editProfileState)async {
    var staus=await Permission.storage.request();
    // if(staus==PermissionStatus.granted){
      try{
        var fpath=fbdatabase().storageRef.child(FirebaseAuth.instance.currentUser!.uid);
         file=await ImagePicker().pickImage(source: ImageSource.gallery);
        showLoader();
        if(file!=null){
          fpath.putFile(File(file!.path)).then((p0) async {
            print(p0);
            hideLoader();
            var image=await fpath.getDownloadURL();
            //user!.image="$image";
            fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).update({"image":image});
            notifyListeners();
            Navigator.pop(MyApp.appnavKey.currentContext!);
          });
        }else{
          hideLoader();
        }

      }catch(e){
        DangerAlertBox(context: MyApp.appnavKey.currentContext,
            title: "Upload failed".tr,
            messageText: "",
            buttonText: "Close".tr
        );
      }
    // }else{
    //   DangerAlertBox(context: MyApp.appnavKey.currentContext,
    //       title: "Need Storage Permission".tr,
    //       messageText: "",
    //       buttonText: "Close".tr
    //   );
    // }
  }

  void changeGender(int value,EditProfileState editProfileState) {
    gender=value;
    notifyListeners();
    editProfileState.setState(() {

    });
  }

  void changeFlag(country) {
    coutry=coutry;
    notifyListeners();
  }

  void saveProfile(EditProfileState editProfileState) async{
    if(name.text.isEmpty){
      DangerAlertBox(context: MyApp.appnavKey.currentContext,
          title: "Name is required".tr,
          messageText: "",
          buttonText: "Close".tr
      );
    }else{
      showLoader();
      try{
        var fcm=await Shared_Preferences.prefGetString("fcm", "");
        var userUpdate=  fbdatabase().getUserJson(name: name.text??"", image: user!.image??"", bio: bio.text??"", uid: "${FirebaseAuth.instance.currentUser!.uid}", fcm: fcm!, gender: gender, friends: 0,number:number!.text!=""?coutry['phoneCode'].toString()+number.text:"",email:email.text??"",birthday:birthday.text??"");
        fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).update(userUpdate);
        hideLoader();
        editProfileState.setState(() {
        });
        SuccessAlertBox(context: MyApp.appnavKey.currentContext,
            title: "Profile saved".tr,
            messageText: "",
            buttonText: "Close".tr
        );
      }catch(e){
        DangerAlertBox(context: MyApp.appnavKey.currentContext,
            title: "Profile failed to save".tr,
            messageText: "",
            buttonText: "Close".tr
        );
      }
    }
  }

  void datetimeset(EditProfileState editProfileState, formattedDate) {
    birthday.text=formattedDate;
    notifyListeners();
    editProfileState.setState(() {

    });
  }

}