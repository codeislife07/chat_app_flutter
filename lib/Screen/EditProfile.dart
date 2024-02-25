import 'dart:io';

import 'package:chatapp/MyBehavior.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Providers/ProfileProvider.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppColors.dart';
import '../function/MyFunction.dart';

class EditProfile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>EditProfileState();


}

class EditProfileState extends State<EditProfile> {

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    ProfileProvider provider=(ModalRoute.of(context)!.settings.arguments as Map)['user'];
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return WillPopScope(
      onWillPop: () async{
        provider.assignData();
        return true;
      },
      child: Scaffold(
        backgroundColor: themeBlack?AppColors.blackbg:AppColors.bg,
        appBar: AppBar(
          leading: BackButton(color: themeBlack?Colors.white:Colors.black,),
          toolbarHeight: 50.h,
          backgroundColor: Colors.transparent,
          title: Text("Complete your profile".tr,style: TextStyle(color: themeBlack?Colors.white:Colors.black,fontSize: 17.sp,fontWeight: FontWeight.bold),),
          elevation: 0,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: [
              Container(
                height: 200,width: 200,
                child: CircleAvatar(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(provider.user!.image==null || provider.user!.image==""?AppString.dImage:provider.user!.image!,fit: BoxFit.fill, height: 200,width: 200, )),
                ),

              ),
              TextButton(onPressed: (){
                provider.changePhoto(this);
              }, child: Text("Change photo".tr,style: TextStyle(fontSize: 15.sp),)),
              SizedBox(height: 10.h,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    Text("Name*".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: themeBlack?AppColors.blackboxbg:Colors.white,
                          border: Border.all(color: themeBlack?AppColors.blackbg:Colors.grey[300]!)
                      ),
                      child: Container(
                        child: TextField(
                          controller: provider.name,
                          onChanged: (value){
                            //provider.searchUsers();
                          },
                          autofocus: false,
                          style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                          decoration: InputDecoration(
                            hintText: "Enter name".tr,
                            hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                            prefixIcon: Icon(Icons.search,color: Colors.transparent,),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    //bio
                    Text("Bio".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: themeBlack?AppColors.blackboxbg:Colors.white,
                          border: Border.all(color: themeBlack?AppColors.blackbg:Colors.grey[300]!)
                      ),
                      child: Container(
                        child: TextField(
                           controller: provider.bio,
                          onChanged: (value){
                            //provider.searchUsers();
                          },
                          autofocus: false,
                          maxLines: 3,
                          maxLength: 40,
                          style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                            hintText: "Enter bio".tr,
                            prefixIcon: Icon(Icons.search,color: Colors.transparent,),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    //email
                    Text("Email".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: themeBlack?AppColors.blackboxbg:Colors.white,
                          border: Border.all(color: themeBlack?AppColors.blackbg:Colors.grey[300]!)
                      ),
                      child: Container(
                        child: TextField(
                          controller: provider.email,
                          onChanged: (value){
                            //provider.searchUsers();
                          },
                          enabled:provider.email.text!=""?false:true,
                          autofocus: false,
                          style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                            hintText: "Enter email".tr,
                            prefixIcon: Icon(Icons.search,color: Colors.transparent,),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    //number
                    Text("Number".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Container(
                      height: 40.h,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            decoration:BoxDecoration(
                                borderRadius: BorderRadius.circular(5.r),
                                color: themeBlack?AppColors.blackboxbg:Colors.white,
                                border: Border.all(color: themeBlack?AppColors.blackboxbg:Colors.grey[300]!)
                            ),
                            child: CountryListPick(
                                appBar: AppBar(
                                  backgroundColor: AppColors.primary,
                                  title: Text('Select Country'.tr),
                                ),
                                // if you need custome picker use this
                                pickerBuilder: (context, CountryCode? countryCode){
                                  return Row(
                                    children: [
                                      Image.asset(
                                        countryCode!.flagUri!,
                                        package: 'country_list_pick',
                                      ),
                                      Icon(Icons.expand_more,color: Colors.grey,)
                                      // Text(countryCode.code!),
                                      // Text(countryCode.dialCode!),
                                    ],
                                  );
                                },

                                // To disable option set to false
                                theme: CountryTheme(
                                  isShowFlag: true,
                                  isShowTitle: false,
                                  isShowCode: false,
                                  isDownIcon: true,
                                  showEnglishName: true,
                                ),
                                // Set default value
                                initialSelection: '+91',
                                // or
                                // initialSelection: 'US'
                                onChanged: (CountryCode? code) {
                                  if(provider.number!=""){
                                    provider.changeFlag({"name": "${code!.name}", "countryCode": "${code!.code}", "phoneCode": "${code!.dialCode}"});
                                  }
                                    // coutry=Country(name: code!.name!, countryCode: code.code!, phoneCode: code.dialCode!);

                                },
                                // Whether to allow the widget to set a custom UI overlay
                                useUiOverlay: true,
                                // Whether the country list should be wrapped in a SafeArea
                                useSafeArea: false
                            ),
                          ),
                          SizedBox(
                            width: 19.w,
                          ),
                          Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: provider.number,
                                  enabled:provider.number.text!=""?false:true,
                                style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                                textAlignVertical: TextAlignVertical.center,autofocus: false,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                                    prefixText:"${provider.coutry['phoneCode']} ",
                                    prefixStyle: TextStyle(color:themeBlack?Colors.white:Colors.black,fontSize: 16),
                                    hintText: "Enter Phone Number",
                                    fillColor: themeBlack?AppColors.blackboxbg:Colors.white,
                                    filled: true,
                                    hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                                    enabledBorder:  OutlineInputBorder(
                                        borderSide:
                                        BorderSide(width: 1, color: themeBlack?AppColors.blackboxbg:Colors.grey[300]!)),
                                    border: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(width: 1, color: themeBlack?AppColors.blackboxbg:Colors.grey[300]!)),
                                    focusedBorder:OutlineInputBorder(
                                        borderSide:
                                        BorderSide(width: 1, color: themeBlack?AppColors.blackboxbg:Colors.grey[300]!))
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    //birthdate
                    Text("Birthdate".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: themeBlack?AppColors.blackboxbg:Colors.white,
                          border: Border.all(color: themeBlack?AppColors.blackbg:Colors.grey[300]!)
                      ),
                      child: Container(
                        child: TextField(
                          controller: provider.birthday,
                          onChanged: (value){
                            //provider.searchUsers();
                          },
                          readOnly: true,
                          onTap: ()async{
                              DateTime? pickedDate = await showDatePicker(
                              context: context, initialDate: DateTime.now(),
                              firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1)
                              );
                              String formattedDates='';
                              if(pickedDate != null ){
                              print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                              formattedDates = formatterDate.format(pickedDate);
                              provider.datetimeset(this,formattedDates);
                              }

                          },
                          autofocus: false,
                          style: TextStyle(color:themeBlack?Colors.white:Colors.black),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: themeBlack?Colors.white30:Colors.grey),
                            hintText: "dd/mm/yyyy".tr,
                            prefixIcon: Icon(Icons.search,color: Colors.transparent,),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    //gender
                    Text("Gender".tr,style: TextStyle(fontSize: 13.sp,color: themeBlack?Colors.white:Colors.black),),
                    Theme(
                      data: ThemeData(unselectedWidgetColor: themeBlack?Colors.white:Colors.black,primaryColor: AppColors.primary),
                      child: Row(
                        children: [
                          Radio(value: 1, groupValue: provider.gender, onChanged: (int? value) {provider.changeGender(value!,this);  },),Text("Male".tr,style: TextStyle(fontSize: 10.sp,color: themeBlack?Colors.white:Colors.black),),
                          Radio(value: 2, groupValue: provider.gender, onChanged: (int? value) { provider.changeGender(value!,this);  },),Text("Female".tr,style: TextStyle(fontSize: 10.sp,color: themeBlack?Colors.white:Colors.black),),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h,),
                    Container(width:double.infinity,child: ElevatedButton(onPressed: (){
                      provider.saveProfile(this);
                    }, child: Text("Save".tr))),
                    SizedBox(height: 20.h,)
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
