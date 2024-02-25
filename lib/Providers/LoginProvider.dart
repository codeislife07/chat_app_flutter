import 'package:chatapp/Providers/HomeProvider.dart';
import 'package:chatapp/Providers/NotifiationProvider.dart';
import 'package:chatapp/Providers/ProfileProvider.dart';
import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/OtpScreen.dart';
import 'package:chatapp/function/MyFunction.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../Screen/MainScreen.dart';
import '../constant/AppString.dart';

class LoginProvider extends ChangeNotifier{

  var number=TextEditingController();

  LoginProvider(){

  }


  void Login(Map<String, String> coutry) async{
    showLoader();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '${coutry['phoneCode']}${number.text}',
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
        Navigator.push(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>OtpScreen("${coutry['phoneCode']}${number.text}",verificationId)), );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // DangerAlertBox(context: MyApp.appnavKey.currentContext,
        //     title: "verification failed".tr,
        //     messageText: "",
        //     buttonText: "Close".tr
        // );
      },
    );

    }

  void googleLogin()async {
    var user=await signInWithGoogle();
    if(user.user!=null){
      Shared_Preferences.prefSetBool(AppString.loginkey, true);
      loadProvider();
      Navigator.pushAndRemoveUntil(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>MainScreen()), (route) => false);

    }else{
      // DangerAlertBox(context: MyApp.appnavKey.currentContext,
      //     title: "verification failed".tr,
      //     buttonText: "Close".tr
      // );
    }
  }
  Future<UserCredential> signInWithGoogle() async {
    showLoader();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    hideLoader();
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  void unknown() async{
    showLoader();
    try {
      final userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      if(userCredential.user!=null){
        hideLoader();
        loadProvider();
        Shared_Preferences.prefSetBool(AppString.loginkey, true);
        Navigator.pushAndRemoveUntil(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>MainScreen()), (route) => false);
      }
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      hideLoader();
      DangerAlertBox(context: MyApp.appnavKey.currentContext,
          title: "verification failed".tr,
          messageText: "",
          buttonText: "Close".tr
      );
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
   }

  void facebookLogin() {

  }

  void loadProvider() {
    var cont=MyApp.appnavKey.currentContext!;
    Provider.of<HomeProvider>(cont ,listen: false);
    Provider.of<ProfileProvider>(cont,listen: false);
    Provider.of<NotificationProvider>(cont,listen: false);
  }

}