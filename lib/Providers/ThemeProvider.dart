import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/Shared_Preference.dart';

class ThemeProvider extends ChangeNotifier{
  bool darkTheme=false;
  ThemeProvider(){
    themecheck();
  }

  void themecheck () async{
    darkTheme=await Shared_Preferences.prefGetBool("theme", false)??false;
    notifyListeners();
  }

  changetheme(){
    darkTheme=!darkTheme;
    print(darkTheme);
    Shared_Preferences.prefSetBool("theme", darkTheme);
    notifyListeners();
  }

}