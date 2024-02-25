import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Screen/FinfingFriends.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gender_picker/gender_picker.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Firebase/firebaseInstance.dart';
import '../Providers/AddFriendsProvider.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';

class AddFriends extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>AddFriendsState();

}

class AddFriendsState extends State<AddFriends> {
  var search=false;


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var provider=context.read<AddFriendsProvider>();
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return Scaffold(
      backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
      appBar: AppBar(
        toolbarHeight: 80.h,
        backgroundColor: Colors.transparent,
        title: Text("Find Friends".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold),),
        elevation: 0,
      ),
      body: search?Container():Center(child: Column(
        children: [
          SizedBox(height: 100.h,),
          GenderPickerWithImage(
            showOtherGender: false,
            verticalAlignedText: false,
            selectedGender: Gender.Male,
            selectedGenderTextStyle: TextStyle(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            unSelectedGenderTextStyle: TextStyle(
                color: themeBlack?Colors.white:Colors.black, fontWeight: FontWeight.normal),
            onChanged: (Gender? gender) {
             provider.changegender(gender!);
            },
            equallyAligned: true,
            animationDuration: Duration(milliseconds: 300),
            isCircular: true,
            // default : true,
            opacityOfGradient: 0.4,
            padding: const EdgeInsets.all(3),
            size: 50, //default : 40
          ),
          SizedBox(height: 100.h,),
          Container(
            width: MediaQuery.of(context).size.width/2,
            height: MediaQuery.of(context).size.width/8,
            child: ElevatedButton(onPressed: (){
              // setState(() {
              //   search=true;
              // });
              var data={
                "id":FirebaseAuth.instance.currentUser!.uid,
                "gender":provider.user!.gender,
                "searchgender":provider.genderIndex
              };
              fbdatabase().database.child("search").child(FirebaseAuth.instance.currentUser!.uid).set(data);
             Navigator.push(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>FindingFriends(provider.user!,provider.users!)));
            }, child: Text("Start".tr)),
          )
        ],
      ),),
    );
  }
}