import 'dart:convert';
import 'dart:ffi' as c;

import 'dart:io' show Platform, Directory;
import 'package:at_chops/at_chops.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:encrypt/encrypt.dart';

final _libExtension = {
  'linux': 'so',
  'macos': 'dylib',
  'windows': 'dll',
}[Platform.operatingSystem];

typedef atchops_aesctr_decrypt = c.Int Function(
  c.Pointer<Utf8>,
  c.UnsignedLong,
  c.Int32,
  c.Pointer<Utf8>,
  c.Pointer<Utf8>,
  c.UnsignedLong,
  c.Pointer<Utf8>,
  c.UnsignedLong,
  c.Pointer<c.UnsignedLong>,
);

typedef AtchopsAesctrDecrypt = int Function(
  c.Pointer<Utf8>,
  int,
  int,
  c.Pointer<Utf8>,
  c.Pointer<Utf8>,
  int,
  c.Pointer<Utf8>,
  int,
  c.Pointer<c.UnsignedLong>,
);

final libPath =
    path.join(Directory.current.path, 'build', 'libatchops.$_libExtension');
final dylib = c.DynamicLibrary.open(libPath);
final decryptPointer = dylib
    .lookup<c.NativeFunction<atchops_aesctr_decrypt>>('atchops_aesctr_decrypt');
final decrypt = decryptPointer.asFunction<AtchopsAesctrDecrypt>();

const _key = "1DPU9OP3CYvamnVBMwGgL7fm8yB1klAap0Uc5Z9R79g=";
const _plaintext = "I like to eat pizza 123";
final _iv = "1234567890ABCDEF";
final _ivDart = IV.fromUtf8(_iv);

main() {
  c.Pointer<Utf8> iv;
  c.Pointer<Utf8> buffer;
  c.Pointer<c.UnsignedLong> outLen;
  test("Dart encrypt - C decrypt", () {
    // Setup the Dart encryption inputs
    final key = AESKey(_key);
    final algorithm = AESEncryptionAlgo(key);
    final ivDart = InitialisationVector(_ivDart.bytes);

    // Do the Dart encryption and data encoding
    final plainBytes = utf8.encode(_plaintext);
    final cipherBytes = algorithm.encrypt(plainBytes, iv: ivDart);
    final cipherText = base64.encode(cipherBytes);

    // Validate the Dart encryption
    expect(cipherText, isNotNull);
    expect(cipherText, isNotEmpty);

    // Setup the C function inputs
    final keyBase64 = _key.toNativeUtf8();
    final keyLength = _key.length;
    final keyBits = 256;
    final cipherTextC = cipherText.toNativeUtf8();
    final cipherTextLength = cipherText.length;
    final bufSize = cipherTextLength;
    iv = _iv.toNativeUtf8();
    buffer = malloc.allocate(bufSize).cast<Utf8>();
    outLen = malloc.allocate(4).cast<c.UnsignedLong>();

    // Call the C function
    int res = decrypt(keyBase64, keyLength, keyBits, iv, cipherTextC,
        cipherTextLength, buffer, bufSize, outLen);

    // Extract the outputs from the C function
    final outLenDart = outLen.value;
    final plainText = buffer.toDartString(length: outLenDart);

    // Free the memory allocated in C
    malloc.free(keyBase64);
    malloc.free(cipherTextC);
    malloc.free(iv);
    malloc.free(buffer);
    malloc.free(outLen);

    // Verify the decrypted plaintext is the same as the original plaintext
    expect(res, 0);
    expect(plainText, _plaintext);
  });
}
