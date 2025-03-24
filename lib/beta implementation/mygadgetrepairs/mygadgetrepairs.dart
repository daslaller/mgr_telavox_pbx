import 'dart:convert';

import 'package:mgr_telavox_pbx/controller.dart';
import 'package:http/http.dart' as http;

class MgrUrl {
  String? _phonenumber;
  String? _uuid;
  Uri? _url;

  MgrUrl({phonenumber, UUID}) {
    _phonenumber = phonenumber;
    _uuid = UUID;

    // if booth variables passes the null check then update parameters to fetch a new url construction.
    if ((phonenumber ?? false) || (UUID ?? false)) {
      updateParameters(phonenumber: phonenumber, uuid: UUID);
    }
  }

  get lastURL => _url;

  get currentPhonenumber => _phonenumber;

  get currentUUID => _uuid;

  void updateParameters({required phonenumber, required uuid}) {
    _uuid = uuid;
    _phonenumber = phonenumber;
    _url = fetchMgrURL(phonenumber: phonenumber, uuid: uuid);
    print(
        'updateParameters was called, result = uuid: $_uuid, phonenumber: $_phonenumber, url/fetch result: $_url');
  }

  fetchMgrURL({uuid, phonenumber, bool? redirect}) {
    uuid = uuid ?? _uuid;
    phonenumber = phonenumber ?? _phonenumber;
    return 'https://www.mygadgetrepairs.com/external/pbx-call.cfm'
        '?uuid=$uuid'
        '&did=$phonenumber'
        '&type=json'
        '${(redirect == null || redirect == false) ? '' : '&redirect=yes'}';
  }
}
