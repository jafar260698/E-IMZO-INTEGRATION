import '../gost/cipher_parameters.dart';

class KeyParameter extends CipherParameters {
  List<int> _key;
  KeyParameter(this._key);
  List<int> get Key => this._key;
}
