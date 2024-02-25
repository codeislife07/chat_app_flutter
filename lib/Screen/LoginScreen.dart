import 'package:chatapp/MyBehavior.dart';
import 'package:chatapp/Providers/LoginProvider.dart';
import 'package:chatapp/constant/AppColors.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Providers/ThemeProvider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  var coutry={"name": "India", "countryCode": "IN", "phoneCode": "+91"};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var themeBlack=false;
    var provider=Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor:themeBlack?AppColors.blackbg:AppColors.bg,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView(
          children: [
            SizedBox(height: 10.h,),
            Image.asset("assets/images/ic_login.png",height: 250.h,width: 100.w,),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider()),
                      SizedBox(
                        width: 10.w,
                      ),
                      Center(child: Text("Log in or sign up".tr)),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 40.h,
                    width: double.infinity,
                    child: Row(
                      children: [
                        // CountryPhoneCodePicker.withDefaultSelectedCountry(
                        //   borderRadius: 5,
                        //   borderWidth: 1,
                        //   borderColor: Colors.grey[300]!,
                        //   style: const TextStyle(fontSize: 16),
                        //   searchBarHintText: 'Search by name',
                        //   defaultCountryCode: Country(name: coutry.name, countryCode: coutry.code, phoneCode: coutry.phoneCode)
                        // ),
                        //
                        Container(
                          decoration:BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!)
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
                                setState(() {
                                  coutry={"name": "${code!.name}", "countryCode": "${code!.code}", "phoneCode": "${code!.dialCode}"};
                                  // coutry=Country(name: code!.name!, countryCode: code.code!, phoneCode: code.dialCode!);
                                });
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
                              textAlignVertical: TextAlignVertical.center,autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                                  prefixText:"${coutry['phoneCode']} ",
                                  prefixStyle: TextStyle(color: Colors.black,fontSize: 16),
                                  hintText: "Enter Phone Number",
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey[300]!),
                                  enabledBorder:  OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1, color: Colors.grey[300]!)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1, color: Colors.grey[300]!)),
                                  focusedBorder:OutlineInputBorder(
                                      borderSide:
                                      BorderSide(width: 1, color: Colors.grey[300]!))
                              ),

                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.all(15.h))),
                          onPressed: () {
                           provider.Login(coutry);
                          },
                          child: Text("Continue".tr))),
                  SizedBox(
                    height: 10.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider()),
                      SizedBox(
                        width: 10.w,
                      ),
                      Center(child: Text("or".tr)),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: double.infinity,
                    child: SignInButton(
                      shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        side: BorderSide(color: Colors.grey[300]!)
                      ),
                      padding:EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
                      Buttons.Google,
                      text: "Continue with Google".tr,
                      elevation: 0,
                      onPressed: () {
                        provider.googleLogin();
                      },
                    )
                  ),
                  SizedBox(height: 10.h,),
                  GestureDetector(
                    onTap: (){
                      provider.unknown();
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.r),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Center(child: Text("Continue  with unknown login".tr,style: TextStyle(color: Colors.grey),)),
                          )),
                    ),
                  ),
                  // Container(
                  //     width: double.infinity,
                  //     child: SignInButton(
                  //       shape:RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(5.r),
                  //           side: BorderSide(color: Colors.grey[300]!)
                  //       ),
                  //       padding:EdgeInsets.symmetric(horizontal: 0.w,vertical: 10.h),
                  //       Buttons.Facebook,
                  //       text: "Continue with Facebook".tr,
                  //       elevation: 0,
                  //       onPressed: () {
                  //        provider.facebookLogin();
                  //       },
                  //     )
                  // ),
                  SizedBox(height: 10.h,),
                  Text("By continuing,you agree to our".tr),
                  Text("Term of service  Privacy Policy  Content Policy")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
