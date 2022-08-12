
import 'dart:async';
import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'apiservice/api_provider.dart';
import 'crc32.dart';
import 'crypto_non_null/gost_hash.dart';
import 'model/deep_link_response.dart';


class LoginViewModel extends BaseViewModel{
  late BuildContext context;
  var _apiProvider = ApiProvider();
  var _sendController = new TextEditingController();
  TextEditingController get sendController => _sendController;

  var _checkController = new TextEditingController();
  TextEditingController get checkController => _checkController;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDeepLinkMessageVisible = false;
  bool get isDeepLinkMessageVisible => _isDeepLinkMessageVisible;
  bool _isVisible = false;
  bool get isVisible => _isVisible;

  Color _color=Colors.green;
  Color get color=>_color;

  String? documentId;
  String? siteId;
  String? challange;

  String responseSend="";
  String successMessage="";
  bool _successStatus = false;

  void setContext(BuildContext context) {
    this.context = context;
  }

    Future<void> callbackNewImzo() async {
    String direct = "uz.yt.idcard.eimzo";
    if (Platform.isAndroid||Platform.isIOS) {
      bool isInstalled = await DeviceApps.isAppInstalled(direct);
      if (isInstalled != false) {
        send();
      } else {
        String url = "https://play.google.com/store/apps/details?id=$direct";
        if (await canLaunch(url))
          await launch(url);
        else
          throw 'Could not launch $url';
      }
    }
  }

  void send() {
    _isLoading = true;
    notifyListeners();
    _apiProvider
        .getDeepLink(_sendController.text.toString())
        .then((value) => {
      if (value != null)
        {
          print("Response Jafar $value"),
          crc32Function(value),
        }
    }).catchError((onError) {
         responseSend="Xatolik $onError";
         _color=Colors.red;
         _isVisible=true;
         print(onError);
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  void crc32Function(DeepLinkResponse response) {
     documentId = response.documentId;
     challange = response.challange;
     siteId = response.siteId;
     responseSend="DokumentId: $documentId \n SiteID: $siteId\n Challange: $challange";
     _color=Colors.green;
     _isVisible=true;
     notifyListeners();
  }

  void deepLink(){
    _successStatus=false;
    notifyListeners();
    print("///////////\nsiteId: $siteId \n documentId: $documentId \n///////////");

    var raw = challange?.codeUnits;
    // in case of document(json,xml) to sign
    // var raw = document?.codeUnits;
    var doc64_send2VerifyFunc = base64Encode(raw!);
    // send doc64_send2VerifyFunc to backend

    print("///////////\nchallange: $challange \n challange hash: ${GostHash.hashGost2Hex(raw!)}\n///////////");
    print("///////////\nchallange b64: ${doc64_send2VerifyFunc}\n///////////");

    
    var docHash = GostHash.hashGost2Hex(raw);
    var code = siteId! + documentId! + docHash!;
    var crc32 = Crc32.calcHex(code);
    code += crc32;
    print("Deep Code $code");
    _launchURL(code);
  }

  _launchURL(String code) async {
    var _deepLink = 'eimzo://sign?qc=$code';
    await canLaunch(_deepLink)
        ? launch(_deepLink)
        : throw 'Could not launch $_deepLink';
    recursion(102);
  }


  void recursion(int i) {
    print(i);
    if (!_successStatus) {
      if (i > 0) {
        checkStatus();
        new Timer(Duration(seconds: 3), () => {i -= 3, recursion(i)});
      } else {
        print("Tizimga kirish ma'lumotlari yangilandi. Boshqadan urinib ko'ring");
        return;
      }
    } else {
      i = 0;
      print("Muvaffaqiyatli bajarildi");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Muvaffaqiyatli bajarildi"),
      ));
      successMessage="Muvaffaqiyatli bajarildi";
      _isDeepLinkMessageVisible=true;
      notifyListeners();
      // getUserDataByDocumentID();
      return;
    }
  }

  void checkStatus() {
    _apiProvider.checkStatus(documentId,_checkController.text.toString()).then((value) {
      if (value.status == 1) {
        _successStatus = true;
      }
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error $onError"),
      ));
      successMessage="Error $onError";
       print("Error $onError");
    });
  }
}
