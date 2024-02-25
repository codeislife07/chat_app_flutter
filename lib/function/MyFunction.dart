import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/constant/AppColors.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constant/AppString.dart';
import 'package:intl/intl.dart';

import '../main.dart';

final DateTime now = DateTime.now();
final DateFormat formatterDate = DateFormat('dd-MM-yyyy');
final DateFormat formatterTime = DateFormat('h:mm a');
final DateFormat formatterDateTime = DateFormat('dd-MM-yyyy h:mm a');

showLoader(){
  showDialog(

      barrierDismissible:false,
      context: MyApp.appnavKey.currentContext!, builder: (BuildContext context) {
    return  AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(30),
      ),
      content: Container(
          height: 80,width: 80,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
          ),
          child: Center(child: SpinKitFadingCube(
            //color: Colors.white,
            size: 50.0,
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                ),
              );
            },
            //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
          ),)),
    );
  });
}

hideLoader(){
  Navigator.pop( MyApp.appnavKey.currentContext!);
}


Widget loadImage({required String url, double? height, double? width,required bool cover}){
  return CachedNetworkImage(
    imageUrl:url,
    //height: height,width: width,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: imageProvider,
            fit: cover?BoxFit.cover:BoxFit.fill,
            ),
      ),
    ),
    placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Colors.white,)),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );

}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning,';
  }
  if (hour < 17) {
    return 'Good Afternoon,';
  }
  return 'Good Evening,';
}

ImageProvidr({required String url, double? height, double? width,required bool cover}){
  return CachedNetworkImageProvider(
    url,
  );
}
logout()async{
var l=(await Shared_Preferences.prefGetBool(AppString.loginkey, false))??false;
if(!l){
  Navigator.pushNamedAndRemoveUntil(MyApp.appnavKey.currentContext!, AppString.loginScreen, (route) => false);
}
}




// enCrypt(String text){
//   final b64key = Key.fromUtf8(base64Url.encode(AppString().keyEncrypt.bytes));
//   final fernet = Fernet(b64key);
//   final encrypter = Encrypter(fernet);
//   final encrypted = encrypter.encrypt(text);
//   return encrypted.bytes;
//}

// deCrypt(Uint8List text){
//   final b64key = Key.fromUtf8(base64Url.encode(AppString().keyEncrypt.bytes));
//   final fernet = Fernet(b64key);
//   final encrypter = Encrypter(fernet);
//   final decrypted = encrypter.decrypt(Encrypted(text));
//   return decrypted;
// }
