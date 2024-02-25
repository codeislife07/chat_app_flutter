import 'package:chatapp/Providers/SearchProvider.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:chatapp/function/MyFunction.dart';
import 'package:chatapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../MyBehavior.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';

class SearchScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var provider=Provider.of<SearchProvider>(context);
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return Scaffold(
        backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
        body:Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                //borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:5.w,vertical: 10.h),
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: themeBlack?AppColors.blackboxbg:Colors.white,
                            border: Border.all(color: themeBlack?AppColors.blackbg:Colors.grey[300]!)
                        ),
                        child: IntrinsicHeight(
                          child: Container(
                            child: TextField(
                              controller: provider.search,
                              onChanged: (value){
                                provider.searchUsers();
                              },
                              autofocus: false,
                              style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                                hintText: "Search name".tr,
                                prefixIcon: Icon(Icons.search,color: AppColors.primaryDark,),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    provider.local?Container(
                      child: Center(child: Text("Search Users")),
                    ):provider.users.length==0?Center(child: Text("No users"),):ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: provider.users.length, itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0.h),
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeBlack?AppColors.blackboxbg:Colors.white,
                            borderRadius: BorderRadius.circular(10.r)
                          ),
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pushNamed(MyApp.appnavKey.currentContext!, AppString.searchUserScreen,arguments: {'user':provider.users[index].uid});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0.h),
                              child: ListTile(
                                leading: SizedBox(
                                  height: 50,width: 50,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: loadImage(url: provider.users[index].image==""?AppString.dImage:provider.users[index].image!, cover: true))
                                ),
                                title: Text("${provider.users[index].name}",style: TextStyle(fontWeight: FontWeight.w600,color: themeBlack?Colors.white:Colors.black),maxLines: 2,),
                                // subtitle: provider.users[index].bio==""?Container():Text("${provider.users[index].bio}",style: TextStyle(fontWeight: FontWeight.w600),maxLines: 2,),
                                //trailing:Text("${provider.users[index].friends} friends")
                                // ElevatedButton(onPressed: (){
                                //   provider.sendrequest(index);
                                // },child: Text("Request"),),
                              ),
                            ),
                          ),
                        ),
                      );
                    },

                    ),
                  ],
                ),
              ),
            )
        )
    );
  }
}