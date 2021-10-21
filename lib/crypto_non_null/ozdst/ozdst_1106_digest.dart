
import '../gost/gost_28147_engine.dart';
import '../gost/key_parameter.dart';
import '../gost/parameters_with_sbox.dart';

class OzDSt1106Digest {

  static final _DIGEST_LENGTH = 32;

  var _H = new List.filled(32,0);
  var _L = new List.filled(32,0);
  var _M = new List.filled(32,0);
  var _Sum = new List.filled(32,0);
  List<List<int>?> _C = new List.filled(4, null);

  var _xBuf = new List.filled(32,0);
  int _xBufOff = 0;
  int _byteCount = 0;

  var _cipher = new GOST28147Engine();
  List<int> _sBox = [];

  static _arraycopy(List<int> inp, int inOff, List<int> out, int outOff, int length) {
    for (int i = 0; i < length; i++) {
      if (i + inOff >= inp.length) break;
      out[i + outOff] = inp[i + inOff];
    }
  }

  OzDSt1106Digest(List<int> sBoxParam) {
    if (sBoxParam == null) {
      this._sBox = GOST28147Engine.getSBox("D_A");
    } else {
      this._sBox = new List.filled(sBoxParam.length,0);
      _arraycopy(sBoxParam, 0, this._sBox, 0, sBoxParam.length);
    }
    this._cipher.init(true, new ParametersWithSBox(null, this._sBox));
    this.reset();
  }

  String get AlgorithmName => "OzDSt1106";

  int get DigestSize =>OzDSt1106Digest._DIGEST_LENGTH;

  void updateByte(int inp) {
    this._xBuf[this._xBufOff++] = inp;
    if (this._xBufOff == this._xBuf.length) {
      this._sumByteArray(this._xBuf); // calc sum M
      this._processBlock(this._xBuf, 0);
      this._xBufOff = 0;
    }
    this._byteCount++;
  }

  void updateBuffer(List<int> inp, int inOff, int len) {
    while ((this._xBufOff != 0) && (len > 0)) {
      this.updateByte(inp[inOff]);
      inOff++;
      len--;
    }

    while (len > this._xBuf.length) {
      _arraycopy(inp, inOff, this._xBuf, 0, this._xBuf.length);
      this._sumByteArray(this._xBuf); // calc sum M
      this._processBlock(this._xBuf, 0);
      inOff += this._xBuf.length;
      len -= this._xBuf.length;
      this._byteCount += this._xBuf.length;
    }

    // load in the remainder.
    while (len > 0) {
      this.updateByte(inp[inOff]);
      inOff++;
      len--;
    }
  }

  // (i + 1 + 4(k - 1)) = 8i + k      i = 0-3, k = 1-8
  var _K = new List.filled(32, 0);
  List<int> _P(List<int> inp) {
    for (int k = 0; k < 8; k++) {
      this._K[4 * k] = inp[k];
      this._K[1 + 4 * k] = inp[8 + k];
      this._K[2 + 4 * k] = inp[16 + k];
      this._K[3 + 4 * k] = inp[24 + k];
    }
    return this._K;
  }

//A (x) = (x0 ^ x1) || x3 || x2 || x1
  var _a = new List.filled(8, 0);
  List<int> _A(List<int> inp) {
    for (int j = 0; j < 8; j++) {
      this._a[j] = (inp[j] ^ inp[j + 8]) & 0xFF;
    }
    _arraycopy(inp, 8, inp, 0, 24);
    _arraycopy(this._a, 0, inp, 24, 8);
    return inp;
  }

  //Encrypt function, ECB mode
  void _E(List<int> key, List<int> s, int sOff, List<int> inp, int inOff) {
    this._cipher.init(true, new KeyParameter(key));
    this._cipher.processBlock(inp, inOff, s, sOff);
  }

// (in:) n16||..||n1 ==> (out:) n1^n2^n3^n4^n13^n16||n16||..||n2
  var _wS = new List.filled(16, 0);
  var _w_S = new List.filled(16, 0);
  void _fw(List<int> inp) {
    _cpyBytesToShort(inp, this._wS);
    this._w_S[15] = (this._wS[0] ^ this._wS[1] ^ this._wS[2] ^ this._wS[3] ^ this._wS[12] ^ this._wS[15]) & 0xFFFF;
    _arraycopy(this._wS, 1, this._w_S, 0, 15);
    _cpyShortToBytes(this._w_S, inp);
  }

  var _S = new List.filled(32, 0);
  var _U = new List.filled(32, 0);
  var _V = new List.filled(32, 0);
  var _W = new List.filled(32, 0);
  // block processing
  void _processBlock(List<int> inp, int inOff) {
    _arraycopy(inp, inOff, this._M, 0, 32);

    //key step 1

    // H = h3 || h2 || h1 || h0
    // S = s3 || s2 || s1 || s0
    _arraycopy(this._H, 0, this._U, 0, 32);
    _arraycopy(this._M, 0, this._V, 0, 32);

    for (int j = 0; j < 32; j++) {
      this._W[j] = (this._U[j] ^ this._V[j]) & 0xFF;
    }

    // Encrypt gost28147-ECB
    this._E(this._P(this._W), this._S, 0, this._H, 0); // s0 = EK0 [h0]

    //keys step 2,3,4
    for (int i = 1; i < 4; i++) {
      List<int> tmpA = this._A(this._U);
      for (int j = 0; j < 32; j++) {
        this._U[j] = (tmpA[j] ^ this._C[i]![j]) & 0xFF;
      }
      this._V = this._A(this._A(this._V));
      for (int j = 0; j < 32; j++) {
        this._W[j] = (this._U[j] ^ this._V[j]) & 0xFF;
      }
      // Encrypt gost28147-ECB
      this._E(this._P(this._W), this._S, i * 8, this._H, i * 8); // si = EKi [hi]
    }

    // x(M, H) = y61(H^y(M^y12(S)))
    for (int n = 0; n < 12; n++) {
      this._fw(this._S);
    }
    for (int n = 0; n < 32; n++) {
    this._S[n] = (this._S[n] ^ this._M[n]) & 0xFF;
    }

    this._fw(this._S);

    for (int n = 0; n < 32; n++) {
      this._S[n] = (this._H[n] ^ this._S[n]) & 0xFF;
    }
    for (int n = 0; n < 61; n++) {
      this._fw(this._S);
    }
    _arraycopy(this._S, 0, this._H, 0, this._H.length);
  }

  static void _intToLittleEndian(int n,List<int> bs, int off) {
    bs[off] = (n) & 0xFF;
    bs[++off] = ((n & 0xFFFFFFFF) >> 8) & 0xFF;
    bs[++off] = ((n & 0xFFFFFFFF) >> 16) & 0xFF;
    bs[++off] = ((n & 0xFFFFFFFF) >> 24) & 0xFF;
  }

  static void _longToLittleEndian(int n, List<int> bs, int off) {
    _intToLittleEndian((n) & 0xffffffff, bs, off);
    // JAVASCIPT CANNOT MAKE (n >>> 32)
    //this.intToLittleEndian((n >>> 32) & 0xffffffff, bs, off + 4);
  }

  void finish() {
    _longToLittleEndian(this._byteCount * 8, this._L, 0); // get length into L (byteCount * 8 = bitCount)

    while (this._xBufOff != 0) {
      this.updateByte(0 & 0xFF);
    }

    this._processBlock(this._L, 0);
    this._processBlock(this._Sum, 0);
  }

  int doFinal(List<int> out, int outOff) {
    this.finish();
    _arraycopy(this._H, 0, out, outOff, this._H.length);
    this.reset();
    return OzDSt1106Digest._DIGEST_LENGTH;
  }

  /**
   * reset the chaining variables to the IV values.
   */
  List<int> _C2 = [
    0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF,
    0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0xFF,
    0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF
  ];

  void reset() {
    for(int i=0; i<this._C.length;i++){
      this._C[i] = new List.filled(32, 0);
    }
    this._byteCount = 0;
    this._xBufOff = 0;

    this._H.fillRange(0, this._H.length, 0);
    this._L.fillRange(0, this._L.length, 0);
    this._M.fillRange(0, this._M.length, 0);
    this._C[1]!.fillRange(0, this._C[1]!.length, 0);
    this._C[3]!.fillRange(0, this._C[3]!.length, 0);
    this._Sum.fillRange(0, this._Sum.length, 0);
    this._xBuf.fillRange(0, this._xBuf.length, 0);

    // for (let i = 0; i < this.H.length; i++) {
    //     this.H[i] = 0;  // start vector H
    // }
    // for (let i = 0; i < this.L.length; i++) {
    //     this.L[i] = 0;
    // }
    // for (let i = 0; i < this.M.length; i++) {
    //     this.M[i] = 0;
    // }
    // for (let i = 0; i < this.C[1].length; i++) {
    //     this.C[1][i] = 0;  // real index C = +1 because index array with 0.
    // }
    // for (let i = 0; i < this.C[3].length; i++) {
    //     this.C[3][i] = 0;
    // }
    // for (let i = 0; i < this.Sum.length; i++) {
    //     this.Sum[i] = 0;
    // }
    // for (let i = 0; i < this.xBuf.length; i++) {
    //     this.xBuf[i] = 0;
    // }

    _arraycopy(this._C2, 0, this._C[2]!, 0, this._C2.length);
  }

  //  256 bitsblock modul -> (Sum + a mod (2^256))
  void _sumByteArray(List<int> inp) {
    int carry = 0;
    for (int i = 0; i != this._Sum.length; i++) {
      int sum = (this._Sum[i] & 0xff) + (inp[i] & 0xff) + carry;
      this._Sum[i] = sum & 0xFF;
      carry = (sum & 0xFFFFFFFF) >> 8;
    }
  }

  void _cpyBytesToShort(List<int> S,List<int> wS) {
    for (int i = 0; i < S.length / 2; i++) {
      wS[i] = (((S[i * 2 + 1] << 8) & 0xFF00) | (S[i * 2] & 0xFF)) & 0xFFFF;
    }
  }

  void _cpyShortToBytes(List<int> wS, List<int> S) {
    for (int i = 0; i < S.length / 2; i++) {
      S[i * 2 + 1] = (wS[i] >> 8) & 0xFF;
      S[i * 2] = wS[i] & 0xFF;
    }
  }

  int get ByteLength => 32;
}