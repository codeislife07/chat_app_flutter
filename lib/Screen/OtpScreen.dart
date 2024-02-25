import 'dart:async';
import 'dart:math';

import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/MainScreen.dart';
import 'package:chatapp/function/MyFunction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:chatapp/MyBehavior.dart';
import 'package:provider/provider.dart';

import '../Providers/HomeProvider.dart';
import '../Providers/NotifiationProvider.dart';
import '../Providers/ProfileProvider.dart';
import '../Providers/ThemeProvider.dart';
import '../constant/AppString.dart';
import '../main.dart';
import '../util/Shared_Preference.dart';

class OtpScreen extends StatefulWidget{
  String number;String verificationId;
  OtpScreen(this.number, this.verificationId);

  @override
  State<StatefulWidget> createState()=>OtpScreenState();

}

class OtpScreenState extends State<OtpScreen> {
  int second=60;
  var otp=TextEditingController();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(second!=0){
        second--;
        setState(() {
        });
      }
    });


  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    var themeBlack=context.read<ThemeProvider>().darkTheme;
    return Scaffold(
      appBar:
      AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black,),
        title: Text("OTP Verification".tr,style: TextStyle(color: Colors.black),),
      ),
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView(
          children: [
              SizedBox(height: 40.h,),
              Center(child: Text("We have sent a verification code to".tr)),
              SizedBox(height: 10.h,),
              Center(child: Text("${widget.number}",style: TextStyle(fontWeight: FontWeight.bold),)),
              SizedBox(height: 40.h,),
              Pinput(
                controller: otp,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyDecorationWith(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: Color.fromRGBO(234, 239, 243, 1),
                ),
              ),
              validator: (s) {
                //return s == '2222' ? null : 'Pin is incorrect';
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin)async {
                  showLoader();
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode:otp.text );
                // Sign the user in (or link) with the credential
                await FirebaseAuth.instance.signInWithCredential(credential);
                if(FirebaseAuth.instance.currentUser!=null){
                  hideLoader();
                    var cont=MyApp.appnavKey.currentContext!;
                    Provider.of<HomeProvider>(cont,listen: false);
                    Provider.of<ProfileProvider>(cont,listen: false);
                    Provider.of<NotificationProvider>(cont,listen: false);

                  Shared_Preferences.prefSetBool(AppString.loginkey, true);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>MainScreen()), (route)  => false);
                }else{
                  hideLoader();
                  DangerAlertBox(context: MyApp.appnavKey.currentContext,
                      title: "verification failed".tr,
                      buttonText: "Close".tr
                  );
                }
              },
            ),
              SizedBox(height: 20.h,),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10.r)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.h),
                        child: ElevatedButton(
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(EdgeInsets.all(10.h)),

                            ),
                            onPressed: second==0?()async{
                              showLoader();
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                phoneNumber: '${widget.number}',
                                verificationCompleted: (PhoneAuthCredential credential) {
                                },
                                verificationFailed: (FirebaseAuthException e) {
                                  hideLoader();
                                  DangerAlertBox(context: MyApp.appnavKey.currentContext,
                                      title: "verification failed".tr,
                                      messageText: "",
                                      buttonText: "Close".tr
                                  );
                                },
                                codeSent: (String verificationId, int? resendToken) {
                                  hideLoader();
                                  Navigator.pushReplacement(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>OtpScreen("${widget.number}",verificationId)), );
                                },
                                codeAutoRetrievalTimeout: (String verificationId) {
                                  // DangerAlertBox(context: MyApp.appnavKey.currentContext,
                                  //     title: "verification failed".tr,
                                  //     messageText: "",
                                  //     buttonText: "Close".tr
                                  // );
                                },
                              );
                            }:null, child: Text(second==0?"Resend OTP".tr:"Resend SMS in ".tr+" $second",style:TextStyle(color: Colors.grey[300]!))),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              )

          ],
        ),
      ),
    );
  }
}