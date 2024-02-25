import 'package:get/get.dart';

import 'Lanjson/EnJson.dart';
import 'Lanjson/HiJson.dart';

class AppTranslations extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en_US':enJson,
    'hi_IN':hiJson,
  };

}