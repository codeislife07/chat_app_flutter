import 'dart:ui';

import 'package:chatapp/lan/StorageService.dart';
import 'package:get/get.dart';

class LanguageController extends GetxController{
  final storage=Get.find<StorageService>();
  final RxString local=Get.locale.toString().obs;


  final Map<String,dynamic> optionslocales={
    'en_US':{
      'languageCode':'en',
      'countryCode':'US',
      'description':'English',
    },
    'hi_IN':{
      'languageCode':'hi',
      'countryCode':'IN',
      'description':'हिंदी',
    },
  };

  void updateLocale(String key){
    final String languageCode=optionslocales[key]['languageCode'];
    final String countryCode=optionslocales[key]['countryCode'];
    Get.updateLocale(Locale(languageCode,countryCode));
    local.value=Get.locale.toString();
    storage.write("languageCode", languageCode);
    storage.write("countryCode", countryCode);
  }

}