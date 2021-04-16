import 'package:eimzo_id_example/crc32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Create Hash', () {
    var textHash =
        'AB7BFF228997A3A9356E90A034B82F1AAF0D4FC0391D6DE1B2D13C7ED20CF7A7'; // Challenge
    var code = '860b' + '8D8C2234' + textHash; //  'siteId' + 'documentId'
    var crc32 = Crc32.calcHex(code);
    code += crc32;
    print(code);
  });
}
