import 'package:chatapp/constant/AppString.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../Providers/SearchUserScreenProvider.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';
import '../function/MyFunction.dart';

class SearchUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var reciver=(ModalRoute.of(context)!.settings.arguments as Map)['user'];
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return ChangeNotifierProvider(
      create: (_)=>SearchUserScreenProvider(reciver),
      child: Consumer(
        builder: (BuildContext context,SearchUserScreenProvider provider, Widget? child)=> Scaffold(
          backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
          appBar: AppBar(
            leading: BackButton(color: themeBlack?Colors.white:Colors.black,),
            toolbarHeight: 80.h,
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
          body:
          provider.user==null
              ? Container()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
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
                              provider.user!.bio==""?Container():Text(provider.user!.bio!,style: TextStyle(fontSize: 10.sp,color: themeBlack?Colors.white:Colors.black),),
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
                              percent: 1,
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
                                    backgroundImage: ImageProvidr(url:provider.user!.image==null || provider.user!.image==""?"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiaLO5Z4Ga_OJMvDSNnn2b_UT6iMUvWU2Btg&usqp=CAU":provider.user!.image!,cover: false),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h,),
              provider.status==null
                  ?ElevatedButton(onPressed: (){provider.sendrequest();}, child: Text("Request"))
                  :provider.status==0
                    ?Row(children: [
                      Spacer(),
                      ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green)
                  ),
                  onPressed: (){
                    provider.acceptRequest();
                  }, child: Text("Accept".tr)),SizedBox(width: 5.w,), ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)
                    ),
                    onPressed: ()async{
                      print("rejet");
                      provider.rejectRequest();
                    }, child: Text("Reject".tr)),Spacer()],)
                    :provider.status==2?ElevatedButton(onPressed: (){}, child: Text("Requested")):Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w,),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h))
                              ),
                              onPressed: (){
                            Navigator.pushNamed(context, AppString.chatScreen,arguments: {"user":provider.user!.uid});
                          },label: Text("Chat",style: TextStyle(fontSize: 20.sp),) ,icon: FaIcon(FontAwesomeIcons.comments,size: 20.sp,)),
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
