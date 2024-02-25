import 'package:chatapp/lan/LanguageController.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings{
  @override
  void dependencies() {
    //see we create this one
    Get.put(LanguageController(),permanent:true);
  }

}