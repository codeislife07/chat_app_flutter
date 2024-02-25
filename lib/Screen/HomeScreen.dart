import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/MyBehavior.dart';
import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Providers/ThemeProvider.dart';
import 'package:chatapp/Screen/ChatScreen.dart';
import 'package:chatapp/Screen/LoginScreen.dart';
import 'package:chatapp/Screen/ProfileScreen.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:chatapp/util/date_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constant/AppColors.dart';
import '../constant/AppString.dart';
import '../function/MyFunction.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    // var provider=context.read<HomeProvider>();
    var provider=Provider.of<HomeProvider>(context);
    return  Scaffold(
        appBar: AppBar(
          toolbarHeight: 50.h,
          backgroundColor: Colors.transparent,
          title: Text("${AppString.appname}",style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold),),
          elevation: 0,
          // actions: [
          //   IconButton(onPressed: (){
          //     Navigator.pushNamed(context, AppString.searchScreen);
          //   }, icon: FaIcon(FontAwesomeIcons.search)),SizedBox(width: 20.w,),
          //   IconButton(onPressed: (){}, icon: FaIcon(FontAwesomeIcons.plus)),SizedBox(width: 20.w,),
          // ],
        ),
        backgroundColor:themeBlack?AppColors.blackbg:AppColors.bg,
        body:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  text: greeting(),style: TextStyle(color: themeBlack?Colors.white:Colors.black),
                  children: [
                    TextSpan(
                      text: provider.CUser==null?"":" ${provider.CUser!.name}",style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w500,color: themeBlack?Colors.white:Colors.black),
                    )
                  ]
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Recent Chat".tr,style: TextStyle(color: themeBlack?Colors.white60:Colors.grey,),),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView(
                  children: [
                    provider.chats.isEmpty?Center(child: provider.loading?CircularProgressIndicator():Text("No recent chats".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black),),):
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: provider.chats.length, itemBuilder: (BuildContext context, int index) {
                          var userr=provider.chats[index].reciver==FirebaseAuth.instance.currentUser!.uid?provider.chats[index].sender:provider.chats[index].reciver;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.0.h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeBlack?AppColors.blackboxbg:Colors.white,
                              borderRadius: BorderRadius.circular(10.r)
                            ),
                            child: GestureDetector(
                              onTap: (){
                                // provider.changevalue(index);
                                 fbdatabase().database.child("recent").child(FirebaseAuth.instance.currentUser!.uid).child(provider.values[userr]!.uid!).update({'number':0});
                                // Get.toNamed(AppString.chatScreen,arguments: {"user":provider.values[userr]!.uid});
                                Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.chatScreen,arguments: {"user":provider.values[userr]!.uid});
                                },
                              child: ListTile(
                                leading: Container(
                                  height: 50, width: 50,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: loadImage(url: provider.values[userr]==null?AppString.dImage:provider.values[userr]!.image!="" && provider.values[userr]!.image!=null ?provider.values[userr]!.image!:AppString.dImage,  cover: true)),
                                ),
                                title: Text(provider.values[userr]==null?"":"${provider.values[userr]!.name}",style: TextStyle(fontWeight: FontWeight.w600,color: themeBlack?Colors.white:Colors.black),),
                                subtitle: Text("${provider.chats[index].msg}",style: TextStyle(color: themeBlack?Colors.white60:Colors.grey,overflow: TextOverflow.ellipsis),maxLines: 1,),
                                trailing:provider.chats[index].number==0?Container(
                                  child: Text(provider.chats[index].time==""?"":DateFormatter.getVerboseDateTimeRepresentation(
                                      context, provider.chats[index].time!),style: TextStyle(color:  Colors.grey[300]!),),
                                ): SizedBox(
                                  height: 30.h,width: 30.w,
                                  child: CircleAvatar(
                                    child: Text("${provider.chats[index].number!}"),
                                  ),
                                )
                              ),
                            ),
                          ),
                        );
                      },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      );
  }

  // DrawerWidget(BuildContext context, HomeProvider provider) {
  //   return Column(
  //     children: [
  //       Container(
  //         color: AppColors.primaryDark,
  //         width: double.infinity,
  //         child: Padding(
  //           padding:  EdgeInsets.symmetric(vertical: 15.w),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SizedBox(height: 20.h,),
  //               provider.CUser==null?Container():Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                         height: 60.h,width: 60.w,
  //                         child: provider.CUser!.image=="" || provider.CUser!.image==null?CircleAvatar(
  //                           //borderRadius: BorderRadius.circular(50.r),
  //                           backgroundImage: AssetImage("assets/images/ic_profile.png"),):CircleAvatar(
  //                           backgroundImage: NetworkImage(provider.CUser!.image!),
  //                         )),
  //                     SizedBox(height: 10.h,),
  //                     Text(provider.CUser!.name.toString(),style: TextStyle(color: Colors.white,fontSize: 16.sp),)
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //
  //       ),
  //       GestureDetector(
  //         onTap: (){
  //           //Navigator.pop(context);
  //           Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen()));
  //         },
  //         child: ListTile(
  //           leading: FaIcon(FontAwesomeIcons.user,color: AppColors.primary,),
  //           title: Text("Profile"),
  //         ),
  //       ),
  //       GestureDetector(
  //         onTap: (){
  //           // Navigator.pop(context);
  //           Navigator.pushNamed(context, AppString.notification);
  //         },
  //         child: ListTile(
  //           leading: FaIcon(FontAwesomeIcons.bell,color: AppColors.primary,),
  //           title: Text("Notifications"),
  //           trailing: Container(
  //             height: 30,width: 30,
  //               decoration: BoxDecoration(
  //                 color: provider.notifications=="0"?Colors.white:Colors.red,
  //                 borderRadius: BorderRadius.circular(50)
  //               ),
  //               child: Padding(
  //             padding: const EdgeInsets.all(2.0),
  //             child: Center(child: Text(provider.notifications,style: TextStyle(color:Colors.white ),)),
  //           )),
  //         ),
  //       ),
  //       GestureDetector(
  //         onTap: (){
  //           //Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen()));
  //         },
  //         child: ListTile(
  //           leading: FaIcon(Icons.settings_outlined,color: AppColors.primary,),
  //           title: Text("Settings"),
  //         ),
  //       ),
  //       SizedBox(height: 5.h,),
  //       Divider(),
  //       SizedBox(height: 5.h,),
  //       GestureDetector(
  //         onTap: ()async{
  //           await  FirebaseAuth.instance.signOut();
  //           Shared_Preferences.prefSetBool(AppString.loginkey, false);
  //           Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginScreen()), (route) => false);
  //         },
  //         child: ListTile(
  //           leading: Icon(Icons.logout,color: AppColors.primary,),
  //           title: Text("Log Out"),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Stream<int> FinfNoNumber(String uid) async*{
    while(true){
      yield await Shared_Preferences.prefGetInt(uid, 0)??0;
    }
  }

}