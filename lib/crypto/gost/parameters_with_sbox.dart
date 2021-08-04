import '../gost/cipher_parameters.dart';

class ParametersWithSBox extends CipherParameters {
  CipherParameters _parameters;
  List<int> _sBox;
  ParametersWithSBox(this._parameters, this._sBox);
  List<int> get SBox => this._sBox;
  CipherParameters get Parameters => this._parameters;
}
