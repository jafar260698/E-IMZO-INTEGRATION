

import 'dart:convert';
import 'dart:io';
import 'package:eimzo_id_example/model/deep_link_response.dart';
import 'package:eimzo_id_example/model/status_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'exceptions.dart';

class ApiProvider {
  Client client = Client();
  BuildContext context;

  final baseUrl = 'https://my.soliq.uz/';

  Future<DeepLinkResponse> getDeepLink(String url) async {
    var responseJson;
    try {
      final response = await client.post(Uri.parse(url), headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8'
      });

      print(response.request.headers.toString());
      var res = _response(response);
      responseJson = DeepLinkResponse.fromJson(res);
    } on FetchDataException catch (e){
      throw FetchDataException("$e");
    }
    return responseJson;
  }


  Future<StatusModel> checkStatus(String docId,String url) async {
    var responseJson;
    var uri = Uri.parse('$url?documentId=$docId');

    try {
      final response = await client
          .post(uri,
          headers:  {
            HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
          }
      );
      var res = _response(response);
      responseJson = StatusModel.fromJson(res);
    } on FetchDataException catch (e){
      throw FetchDataException("No Internet connection $e");
    }
    return responseJson;
  }


  dynamic _response(Response response) {
    print("Status code: ${response.statusCode}");
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
        break;
      case 401:
        throw UnauthorisedException(response.body.toString());
        break;
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
        break;
    }

  }

}
