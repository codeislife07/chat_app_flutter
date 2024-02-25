import 'package:encrypt/encrypt.dart';

class AppString{

  final keyEncrypt = Key.fromUtf8('coding is life subscribe our youtube channel');
  final ivEncrypt = IV.fromLength(16);
  final encrypter = Encrypter(AES(Key.fromUtf8('coding is life s')));
  // final encrypted = encrypter.encrypt(plainText, iv: iv);
  // final decrypted = encrypter.decrypt(encrypted, iv: iv);
  static String loginkey='login';
  static var appname="Chat King";

  static var chatScreen='/chatscreen';
  bool chatscreenapp=false;
  static var homeScreen="/HomeScreen";
  static var loginScreen="/LoginScreen";
  static var profileScreen="/ProfileScreen";
  static var splashScreen="/SplashScreen";
  static var notification="/NotificationScreen";
  static String searchScreen="/SearchScreen";
  static String searchUserScreen="/SearchUserScreen";
  static var editProfile="/EditProfile";

  //default image
  static String dImage="http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp?1658204471";

}