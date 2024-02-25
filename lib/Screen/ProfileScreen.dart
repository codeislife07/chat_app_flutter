import 'dart:io';

import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Providers/ProfileProvider.dart';
import 'package:chatapp/Screen/MainScreen.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MyBehavior.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';
import '../function/MyFunction.dart';
import '../lan/LanguageMenu.dart';

class ProfileScreen extends StatefulWidget{
  MainScreenState mainScreenState;
  ProfileScreen(this.mainScreenState);

  @override
  State<StatefulWidget> createState() =>ProfileScreenState();


}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var provider=Provider.of<ProfileProvider>(context);
    var apptheme=context.read<ThemeProvider>();
    var themeBlack=apptheme.darkTheme;
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50.h,
            backgroundColor: Colors.transparent,
            title: Text("Profile".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold),),
            elevation: 0,
            // actions: [
            //   IconButton(onPressed: (){
            //     Navigator.pushNamed(context, AppString.searchScreen);
            //   }, icon: FaIcon(FontAwesomeIcons.search)),SizedBox(width: 20.w,),
            //   IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.plus)),SizedBox(width: 20.w,),
            // ],
          ),
          backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              provider.user==null?Container():Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0.h,left: 20.w,right: 20.w),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: themeBlack?AppColors.blackboxbg:Colors.white,
                            borderRadius: BorderRadius.circular(10.r)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(18.0.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(provider.user!.name.toString(),style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis),maxLines: 1,),
                                    Text(provider.user!.bio.toString(),style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 13.sp,fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis),maxLines: 2,),
                                    SizedBox(height: 10.h,),
                                    GestureDetector(
                                      onTap: (){
                                       Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.editProfile,arguments: {"user":provider});
                                      },
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Text("Edit Profile".tr,style: TextStyle(color: AppColors.primary),),SizedBox(width: 20.w,),
                                            Icon(Icons.arrow_right,color: AppColors.primary,)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  CircularPercentIndicator(
                                    radius: 70.0.r,
                                    animation: true,
                                    animationDuration: 1200,
                                    lineWidth: 5.0.w,
                                    percent: ((1*provider.percentage)/12),
                                    center: Container(),
                                    circularStrokeCap: CircularStrokeCap.butt,
                                    backgroundColor: Colors.grey[300]!,
                                    progressColor: AppColors.primary,
                                  ),
                                  Positioned(
                                      top: 10.h,
                                      bottom: 10.h,
                                      left: 2.w,right: 2.w,
                                      child: Container(
                                        height: 100.h,width: 100.w,
                                        child: CircleAvatar(
                                          backgroundImage: ImageProvidr(cover:false,url:provider.user!.image==null || provider.user!.image==""?"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiaLO5Z4Ga_OJMvDSNnn2b_UT6iMUvWU2Btg&usqp=CAU":provider.user!.image!),
                                        ),
                                      )),
                                  Positioned(
                                      bottom: 10.h,
                                      left: 40.w,right: 40.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(10.r)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical:3.h,horizontal: 5.w),
                                          child: Center(child: Text("${((100*provider.percentage)/12).round()}%",maxLines:1 ,style: TextStyle(color: Colors.white),)),
                                        ),))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: ListView(
                          children: [
                            SizedBox(height: 20.h,),
                            GestureDetector(
                              onTap: (){
                                final appId = Platform.isAndroid ? '${provider.packageInfo!.packageName}' : 'YOUR_IOS_APP_ID';
                                final url = Uri.parse(
                                  Platform.isAndroid
                                      ? "market://details?id=$appId"
                                      : "https://apps.apple.com/app/id$appId",
                                );
                                launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeBlack?AppColors.blackboxbg:Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xFFf5f6fb),
                                    child: Icon(Icons.star_outline,color: Colors.grey[300]!,),
                                  ),
                                  title: Text("Your Ratings".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black),),
                                  trailing: Icon(Icons.chevron_right_outlined,color: Colors.grey[300]!,),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h,),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: themeBlack?AppColors.blackboxbg:Colors.white
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 15.h,),
                                  Row(children: [
                                    Container(height: 20.h,width: 5.w,decoration: BoxDecoration(
                                        color: AppColors.primary
                                    ),)
                                    ,SizedBox(width: 10.w,),Text("Settings".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontWeight: FontWeight.w600,fontSize: 15.sp),)
                                  ],),
                                  SizedBox(height: 10.h,),
                                  //your orders
                                  // GestureDetector(
                                  //   child: ListTile(
                                  //     leading: CircleAvatar(
                                  //       backgroundColor: Color(0xFFf5f6fb),
                                  //       child: Icon(Icons.language,color: Colors.grey[300]!,),
                                  //     ),
                                  //     title: Text("Change app language".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,),),
                                  //     trailing: LanguageMenu(),
                                  //   ),
                                  // ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  //theme
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xFFf5f6fb),
                                      child: Icon(Icons.dark_mode,color: Colors.grey[300]!,),
                                    ),
                                    title: Text("Dark theme".tr,style: TextStyle(color:themeBlack?Colors.white:Colors.black,),),
                                    trailing: Switch(value: themeBlack, onChanged: (bool value) {
                                      print(value);
                                      apptheme.changetheme();
                                      setState(() {
                                      });
                                      widget.mainScreenState.setState(() {

                                      });
                                    },),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  //privacy policy
                                  GestureDetector(
                                    onTap: (){
                                      launchUrl(
                                        Uri.parse("https://codingislifee.blogspot.com/p/random-chat.html"),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFFf5f6fb),
                                        child: Icon(Icons.privacy_tip_outlined,color: Colors.grey[300]!,),
                                      ),
                                      title: Text("Privacy Policy".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,),),
                                      trailing: Icon(Icons.chevron_right_outlined,color: Colors.grey[300]!,),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  //share app
                                  GestureDetector(
                                    onTap: ()async{
                                      FlutterShare.share(title:"Text",text: "Download this App and Chat with Random persons: https://play.google.com/store/apps/details?id=${provider.packageInfo!.packageName}");
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFFf5f6fb),
                                        child: Icon(Icons.share,color: Colors.grey[300]!,),
                                      ),
                                      title: Text("Share app".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,),),
                                      trailing: Icon(Icons.chevron_right_outlined,color: Colors.grey[300]!,),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                  //more app
                                  GestureDetector(
                                    onTap: (){
                                      final appId = Platform.isAndroid ? '6606606288324698969' : 'YOUR_IOS_APP_ID';
                                      final url = Uri.parse(
                                        Platform.isAndroid
                                            ? "https://play.google.com/store/apps/dev?id=6606606288324698969"
                                            : "https://apps.apple.com/app/id$appId",
                                      );
                                      launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFFf5f6fb),
                                        child: Icon(Icons.apps,color: Colors.grey[300]!,),
                                      ),
                                      title: Text("Install other apps".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,),),
                                      trailing: Icon(Icons.chevron_right_outlined,color: Colors.grey[300]!,),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider(color: Colors.transparent,)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h,),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: themeBlack?AppColors.blackboxbg:Colors.white
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 15.h,),
                                  Row(children: [
                                    Container(height: 20.h,width: 5.w,decoration: BoxDecoration(
                                        color: AppColors.primary
                                    ),)
                                    ,SizedBox(width: 10,),Text("Log out".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontWeight: FontWeight.w600,fontSize: 15.sp),)
                                  ],),
                                  SizedBox(height: 10.h,),
                                  //log out
                                  GestureDetector(
                                    onTap: ()async{
                                      Navigator.pushNamedAndRemoveUntil(MyApp.appnavKey.currentContext!, AppString.loginScreen, (route) => false);
                                      Shared_Preferences.prefSetBool(AppString.loginkey, false);
                                      fbdatabase().getuser.child(FirebaseAuth.instance.currentUser!.uid).update({"fcm":""});
                                      await FirebaseAuth.instance.signOut();
                                      themeBlack?apptheme.changetheme():null;
                                      await GoogleSignIn().signOut();

                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFFf5f6fb),
                                        child: Icon(Icons.logout,color: Colors.grey[300]!,),
                                      ),
                                      title: Text("Log out".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,),),
                                      trailing: Icon(Icons.chevron_right_outlined,color: Colors.grey[300]!,),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 50.w,),
                                      Expanded(child: Divider(color: Colors.transparent,)),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                            SizedBox(height: 20.h,),
                            Row(
                              children: [
                                Spacer(),
                                Text("V ${provider.packageInfo!.version}",style: TextStyle(color: Colors.grey[300]!),),
                                Spacer()
                              ],
                            ),
                            SizedBox(height: 20.h,),
                            SizedBox(height: 20.h,),
                            // SizedBox(height: 20.h,),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}