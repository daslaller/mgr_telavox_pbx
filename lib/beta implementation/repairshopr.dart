import 'dart:convert';

import 'package:mgr_telavox_pbx/controller.dart';
import 'package:http/http.dart' as http;

class MgrUrl {
  var _phonenumber;
  var _UUID;

  mgrUrlConstructor(phonenumber, UUID) {
    _phonenumber = phonenumber;
    _UUID = UUID;
  }

  get currentPhonenumber => _phonenumber;

  get currentUUID => _UUID;

  void updateParameters({required Phonenumber, required UUID}) {
    _UUID = UUID;
    _phonenumber = Phonenumber;
  }

   mgrUrl({uuid, phonenumber}) {
    uuid = uuid ?? _UUID;
    phonenumber = phonenumber ?? _phonenumber;
    return 'https://www.mygadgetrepairs.com/external/pbx-call.cfm'
        '?uuid=$uuid'
        '&did=$phonenumber'
        '&type=json';
  }
}
