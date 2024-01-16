import 'dart:convert';
import 'dart:typed_data';

import 'package:eimzo_id_example/crc32.dart';
import 'package:eimzo_id_example/crypto_non_null/gost_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Create Hash', () {
    var text = 'AB7BFF228997A3A9356E90A034B82F1AAF0D4FC0391D6DE1B2D13C7ED20CF7A7'; // Challenge
    Uint8List byteArray1 = Uint8List(5);
    byteArray1[0] = 10;
    byteArray1[1] = 20;
    byteArray1[2] = 30;
    byteArray1[3] = 40;
    byteArray1[4] = 50;
    var docHash = GostHash.hashGost2Hex(byteArray1);// challange hex
    var crc32 = Crc32.calcHex(docHash);
    docHash += crc32;
    print("crc32: $crc32");
    print("docHash: $docHash");

    signFiles(byteArray1);//2de718140fca2905ff9599f61447c8cb83bf98df82b9c7f124db4a443166eb2b
  });

}


void signFiles(Uint8List files) {
  var siteId = "20e2";
  var documentId = "2F472331";

  String result = utf8.decode(files); // utf8
  String result2 = String.fromCharCodes(files); // utf16
  print("result2 $result2");

  var docHash = GostHash.hashGost2Hex(files);
  var docHash2 = GostHash.hashGost(result);

  print("DocHash $docHash");
  print("DocHash2 $docHash2");

  var code = siteId + documentId + docHash;
  print("Code $code");

  var crc32 = Crc32.calcHex(code);
  print("Crc32 $crc32");

  code += crc32;

  print("Code $code");

}

