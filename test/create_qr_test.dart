import 'package:eimzo_id_example/crc32.dart';
import 'package:eimzo_id_example/crypto/gost_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Create Hash', () {
    var text =
        'AB7BFF228997A3A9356E90A034B82F1AAF0D4FC0391D6DE1B2D13C7ED20CF7A7'; // Challenge
    var docHash = GostHash.hashGost(text);// challange hex
    var crc32 = Crc32.calcHex(docHash);
    docHash += crc32;
    print("crc32: $crc32");
    print("docHash: $docHash");
  });
}
