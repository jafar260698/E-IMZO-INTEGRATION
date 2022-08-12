import 'package:eimzo_id_example/crc32.dart';
import 'package:eimzo_id_example/crypto_non_null/gost_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Create Hash', () {
    var raw =
        'AB7BFF228997A3A9356E90A034B82F1AAF0D4FC0391D6DE1B2D13C7ED20CF7A7'.codeUnits; // Challenge
    var docHash = GostHash.hashGost2Hex(raw);
    var crc32 = Crc32.calcHex(docHash);
    docHash += crc32;
    print("crc32: $crc32");
    print("docHash: $docHash");
  });
}
