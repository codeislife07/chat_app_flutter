import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Providers/NotifiationProvider.dart';
import 'package:chatapp/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../MyBehavior.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';
import '../constant/AppString.dart';
import '../function/MyFunction.dart';
import '../main.dart';

class NotifiationScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var provider=Provider.of<NotificationProvider>(context);
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return Scaffold(
          appBar: AppBar(
            toolbarHeight: 50.h,
            backgroundColor: Colors.transparent,
            title: Text("Notifications".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold),),
            elevation: 0,
          ),
          backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
          body:Padding(
            padding: EdgeInsets.symmetric(horizontal:5.w,vertical: 10.h),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: Column (
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r) ,
                      color: themeBlack?AppColors.blackboxbg:Colors.white
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.h),
                      child: ExpansionTile(
                        leading: SizedBox(
                          height: 50,width: 50,
                          child: CircleAvatar(
                          child: FaIcon(FontAwesomeIcons.bell),
                          ),
                        ),
                        title: Text("Pandding friends requests".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black),),
                        children:provider.noModel.isEmpty?[]:List.generate(provider.noModel.length, (index) => provider.noModel[index].status==0?Padding(
                          padding:  EdgeInsets.symmetric(vertical: 5.h),
                          child: ListTile(
                            leading: SizedBox(
                                height: 50,width: 50,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: loadImage(url: provider.noUser[provider.noModel[index].uid]==null || provider.noUser[provider.noModel[index].uid]!.image==null || provider.noUser[provider.noModel[index].uid]!.image==""?AppString.dImage:provider.noUser[provider.noModel[index].uid]!.image!, cover: true))
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(provider.noUser[provider.noModel[index].uid]!.name!+provider.noModel[index].msg,style: TextStyle(overflow: TextOverflow.ellipsis,color: themeBlack?Colors.white:Colors.black),maxLines: 2,)),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.green)
                                    ),
                                    onPressed: (){
                                      provider.acceptRequest(provider.noModel[index],provider.noUser[provider.noModel[index].uid]!);
                                    }, child: Text("Accept".tr)),SizedBox(width: 5.w,),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.red)
                                    ),
                                    onPressed: (){provider.removeNotification(provider.noModel[index],index);}, child: Text("Reject".tr)),
                              ],
                            ),
                          ),
                        ):Container()),
                      ),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 10.h,),
                  Expanded(
                    child: provider.noUser.isEmpty?Container(child: Center(),):ListView.builder(
                      itemCount: provider.noModel.length, itemBuilder: (BuildContext context, int index) {
                          var time=DateTime.fromMicrosecondsSinceEpoch(int.parse(provider.noModel[index].time));
                          //status 0 is request
                          //status 1 user notification
                          //status 2 another device
                      return provider.noModel[index].status==0
                          ?Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r) ,
                              color: themeBlack?AppColors.blackboxbg:Colors.white
                          ),
                          child: Padding(
                            padding:  EdgeInsets.symmetric(vertical: 5.h),
                            child: ListTile(
                            leading:GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.searchUserScreen,arguments: {"user":provider.noModel[index]!.uid});
                              },
                              child: SizedBox(
                                  height: 50,width: 50,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: loadImage(url: provider.noUser[provider.noModel[index].uid]==null || provider.noUser[provider.noModel[index].uid]!.image==null || provider.noUser[provider.noModel[index].uid]!.image==""?AppString.dImage:provider.noUser[provider.noModel[index].uid]!.image!, cover: true))
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(provider.noUser[provider.noModel[index].uid]!.name!+provider.noModel[index].msg,style: TextStyle(overflow: TextOverflow.ellipsis,color: themeBlack?Colors.white:Colors.black),maxLines: 2,)),
                                ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.green)
                                    ),
                                    onPressed: (){
                                      provider.acceptRequest(provider.noModel[index],provider.noUser[provider.noModel[index].uid]!);
                                    }, child: Text("Accept".tr)),SizedBox(width: 5.w,),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.red)
                                    ),
                                    onPressed: ()async{
                                      print("rejet");
                                      provider.removeNotification(provider.noModel[index],index);
                                    }, child: Text("Reject".tr)),
                              ],
                            ),
                            ),
                          ),
                        ),
                      )
                          :provider.noModel[index].status==1?Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r) ,
                              color: themeBlack?AppColors.blackboxbg:Colors.white
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            child: ListTile(
                            leading: GestureDetector(
                              onTap: (){
                                Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.searchUserScreen,arguments: {"user":provider.noModel[index]!.uid});
                              },
                              child: SizedBox(
                                height: 50,width: 50,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: loadImage(url: provider.noUser[provider.noModel[index].uid]==null || provider.noUser[provider.noModel[index].uid]!.image==null || provider.noUser[provider.noModel[index].uid]!.image==""?AppString.dImage:provider.noUser[provider.noModel[index].uid]!.image!, cover: true))
                              ),
                            ),
                            title: Text(provider.noUser[provider.noModel[index].uid]!.name!+provider.noModel[index].msg,style: TextStyle(color: themeBlack?Colors.white:Colors.black),maxLines: 2,),
                            trailing: Text(DateFormatter.getVerboseDateTimeRepresentation(
                                context,time),style: TextStyle(color: Colors.grey[300]!),),
                            ),
                          ),
                        ))
                          :Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r) ,
                                color: themeBlack?AppColors.blackboxbg:Colors.white
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: (){
                                    // Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.searchUserScreen,arguments: {"user":provider.noModel[index]!.uid});
                                  },
                                  child: SizedBox(
                                      height: 50,width: 50,
                                      child: CircleAvatar(
                                        child: FaIcon(FontAwesomeIcons.searchLocation),
                                      ),
                                  ),
                                ),
                                title: Text(provider.noModel[index].msg,style: TextStyle(color: themeBlack?Colors.white:Colors.black),maxLines: 2,),
                                trailing: Text(DateFormatter.getVerboseDateTimeRepresentation(
                                    context,time),style: TextStyle(color: Colors.grey[300]!),),
                              ),
                            ),
                          ))
                      ;
                    },
                    ),
                  ),
                ],
              ),
            ),
          )
      );
  }
}