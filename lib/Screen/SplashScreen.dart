
import 'package:chatapp/Providers/ThemeProvider.dart';
import 'package:chatapp/Screen/HomeScreen.dart';
import 'package:chatapp/Screen/LoginScreen.dart';
import 'package:chatapp/Screen/MainScreen.dart';
import 'package:chatapp/constant/AppColors.dart';
import 'package:chatapp/constant/AppString.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../util/Shared_Preference.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>SplashScreenState();

}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkForUpdate();
    Future.delayed(Duration(seconds: 5),(){
      logincheck();
      Provider.of<ThemeProvider>(context,listen: false);
    });
  }

  
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      InAppUpdate.performImmediateUpdate()
          .catchError((e) {
        return AppUpdateResult.inAppUpdateFailed;
      });
    }).catchError((e) {
    });
  }

  logincheck()async{
    var login=await Shared_Preferences.prefGetBool(AppString.loginkey, false)??false;
    if(login){
      Navigator.pushAndRemoveUntil(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>MainScreen()), (route) => false);
    }else{
      Navigator.pushAndRemoveUntil(MyApp.appnavKey.currentContext!, MaterialPageRoute(builder: (_)=>LoginScreen()), (route) => false);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              Container(
                  height: 100,width: 100,
                  child: Image.asset("assets/images/ic_logo.png")),
              Spacer()
            ],
          ),SizedBox(height: 50,),
          Text("${AppString.appname}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
          Spacer(),
          Text("Developed by Coding Is Life",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}