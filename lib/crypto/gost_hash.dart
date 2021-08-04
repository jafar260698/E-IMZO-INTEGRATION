

import 'gost/gost_28147_engine.dart';
import 'hex.dart';
import 'ozdst/ozdst_1106_digest.dart';

class GostHash{
  static List<int> hash(List<int> data, {String sBoxName = "D_A"}) {
    var sbox = GOST28147Engine.getSBox(sBoxName);
    var digest = new OzDSt1106Digest(sbox);
    digest.reset();
    digest.updateBuffer(data, 0, data.length);
    var h = new List.filled(digest.DigestSize, 0);
    digest.doFinal(h, 0);
    return h;
  }

  static String hashGost(String text){
    var ba = hash(text.codeUnits);
    return Hex.fromBytes(ba);
  }

}