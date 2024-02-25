import 'package:chatapp/MyBehavior.dart';
import 'package:chatapp/Providers/ChatProvider.dart';
import 'package:chatapp/model/UserModel.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';

class ChatScreens extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>ChatScreenState();


}

class ChatScreenState extends State<ChatScreens> {
  @override
  Widget build(BuildContext context) {
    var reciver=(ModalRoute.of(context)!.settings.arguments as Map)['user'];
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return ChangeNotifierProvider(
      create: (_)=>ChatProvider(reciver),
      child: Consumer(
        builder: (BuildContext context,ChatProvider provider, Widget? child) => Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.black,),
            backgroundColor: Colors.transparent,
            actions: [
              Container(
                height: 40.h,width: 40.w,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
                child: provider.reciver==null?CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                      child: Image.asset("assets/images/ic_profile.png",fit: BoxFit.fill,))):provider.reciver!.image==""?CircleAvatar(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset("assets/images/ic_profile.png",fit: BoxFit.fill))):CircleAvatar(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(provider.reciver!.image!,fit: BoxFit.fill)),),
              ),SizedBox(width: 20.w,)

            ],
            toolbarHeight: 100,
            elevation: 0 ,
            title: Text(provider.reciver==null?"":provider.reciver!.name.toString(),style: TextStyle(color: Colors.black),),
          ),
          backgroundColor: AppColors.bg,
          body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r),topRight: Radius.circular(30.r))
            ),
            child: Column(
              children: [
                Expanded(child: Container(
                  child: RefreshIndicator(
                    onRefresh: ()async {
                      provider.fetchlist();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: ListView.builder(
                          // reverse: true,
                          controller: provider.scrolController,
                          itemCount: provider.chats.length, itemBuilder: (BuildContext context, int index) {
                          return provider.chats[index].sender==provider.reciver!.uid?Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width/5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(20.r),topLeft: Radius.circular(20.r),bottomRight: Radius.circular(20.r)),
                                          border: Border.all(color: Colors.grey[300]!)
                                      ),

                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 8.h),
                                              child: Text("${provider.chats[index].msg}",//softWrap: true,
                                                style: TextStyle(color: Colors.white,overflow: TextOverflow.fade,),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width/2 ,)
                                ],
                              ),
                            ),
                          ):Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 8.h),
                            child: Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Align(
                                  //     alignment:Alignment.topRight,
                                  //     child: Text("${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}",textAlign: TextAlign.right,)),
                                  Padding(
                                    padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width/5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(topRight: Radius.circular(20.r),topLeft: Radius.circular(20.r),bottomLeft: Radius.circular(20.r)),
                                          border: Border.all(color: Colors.grey[300]!)
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w,vertical: 8.h),
                                              child: Text("${provider.chats[index].msg}",//softWrap: true,
                                                style: TextStyle(overflow: TextOverflow.fade,),),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width/2 ,)
                                ],
                              ),
                            ),
                          );
                        },
                        ),
                      ),
                    ),
                  ),
                )),
                Row(
                  children: [

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                            //    color: Colors.green
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10.w,),
                              Expanded(child: TextField(
                                //controller: provider.msg,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter Your Message".tr,
                                  hintStyle: TextStyle(fontSize: 10.sp)
                                ),
                              )),
                              SizedBox(width: 10.w,),


                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.primary
                      ),
                      child: IconButton(onPressed: (){
                        provider.sendMessage("");
                      }, icon: FaIcon(FontAwesomeIcons.paperPlane,color: Colors.white,)),
                    ),
                    SizedBox(width: 10.w,)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    Shared_Preferences.prefSetString("reciver", "");
    super.dispose();

  }

}