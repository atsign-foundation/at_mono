import 'dart:convert';
import 'dart:ffi' as c;

import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:at_chops/at_chops.dart';
import 'package:encrypt/encrypt.dart';

final _libExtension = {
  'linux': 'so',
  'macos': 'dylib',
  'windows': 'dll',
}[Platform.operatingSystem];

typedef atchops_aesctr_encrypt = c.Int Function(
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

typedef AtchopsAesctrEncrypt = int Function(
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
    path.join(Directory.current.path, 'atchops', 'libatchops.$_libExtension');
final dylib = c.DynamicLibrary.open(libPath);
final encryptPointer = dylib
    .lookup<c.NativeFunction<atchops_aesctr_encrypt>>('atchops_aesctr_encrypt');
final encrypt = encryptPointer.asFunction<AtchopsAesctrEncrypt>();

const _key = "1DPU9OP3CYvamnVBMwGgL7fm8yB1klAap0Uc5Z9R79g=";
const _plaintext = "I like to eat pizza 123";
final _iv = "1234567890ABCDEF";
final _ivDart = IV.fromUtf8(_iv);

main() {
  c.Pointer<Utf8> iv;
  c.Pointer<Utf8> buffer;
  c.Pointer<c.UnsignedLong> outLen;
  test("C encrypt - Dart decrypt", () {
    // Make sure that the iv is 16 bytes
    expect(_iv.length, 16);

    // Setup the C function inputs
    final keyBase64 = _key.toNativeUtf8();
    final keyLength = _key.length;
    final keyBits = 256;
    final plainText = _plaintext.toNativeUtf8();
    final plainTextLength = _plaintext.length;
    final bufSize = plainTextLength * 3;
    iv = _iv.toNativeUtf8();
    buffer = malloc.allocate(bufSize).cast<Utf8>();
    outLen = malloc.allocate(4).cast<c.UnsignedLong>();

    // Call the C function
    int res = encrypt(keyBase64, keyLength, keyBits, iv, plainText,
        plainTextLength, buffer, bufSize, outLen);

    // Extract the outputs from the C function
    final outLenDart = outLen.value;
    final cipherText = buffer.toDartString(length: outLenDart);

    // Free the memory allocated in C
    malloc.free(keyBase64);
    malloc.free(plainText);
    malloc.free(iv);
    malloc.free(buffer);
    malloc.free(outLen);

    // Validate the encrypt call has a success signal and the ciphertext is not empty
    expect(res, 0);
    expect(cipherText, isNotNull);
    expect(cipherText, isNotEmpty);

    // Setup the Dart decryption inputs
    final key = AESKey(_key);
    final algorithm = AESEncryptionAlgo(key);
    final ivDart = InitialisationVector(_ivDart.bytes);

    // Do the Dart decryption and data decoding
    final cipherBytes = base64Decode(cipherText);
    final plainBytes = algorithm.decrypt(cipherBytes, iv: ivDart);
    final plainTextOut = utf8.decode(plainBytes);

    // Verify the decrypted plaintext is the same as the original plaintext
    expect(plainTextOut, _plaintext);
  });
}
