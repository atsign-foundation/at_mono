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

final libPath =
    path.join(Directory.current.path, 'build', 'libatchops.$_libExtension');
final dylib = c.DynamicLibrary.open(libPath);

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

const _key = "1DPU9OP3CYvamnVBMwGgL7fm8yB1klAap0Uc5Z9R79g=";
const _plaintext = "I like to eat pizza 123";
main() {
  c.Pointer<Utf8> iv;
  c.Pointer<Utf8> buffer;
  c.Pointer<c.UnsignedLong> outlen;
  test("C encrypt - Dart decrypt", () {
    // Setup the C function pointer
    final encryptPointer =
        dylib.lookup<c.NativeFunction<atchops_aesctr_encrypt>>(
            'atchops_aesctr_encrypt');
    final encrypt = encryptPointer.asFunction<AtchopsAesctrEncrypt>();

    // Setup the C function inputs
    final keybase64 = _key.toNativeUtf8();
    final keyLength = _key.length;
    final keyBits = 256;
    final plaintext = _plaintext.toNativeUtf8();
    final plaintextLength = _plaintext.length;
    final bufSize = plaintextLength * 3;
    iv = calloc
        .allocate(16)
        .cast<Utf8>(); // calloc allocates memory as all zeros
    buffer = malloc.allocate(bufSize).cast<Utf8>();
    outlen = malloc.allocate(4).cast<c.UnsignedLong>();

    // Call the C function
    int res = encrypt(keybase64, keyLength, keyBits, iv, plaintext,
        plaintextLength, buffer, bufSize, outlen);

    // Extract the outputs from the C function
    final outLen = outlen.value;
    final ciphertext = buffer.toDartString(length: outLen);

    // Free the memory allocated in C
    calloc.free(iv);
    malloc.free(buffer);
    malloc.free(outlen);

    // Validate the encrypt call has a success signal and the ciphertext is not empty
    expect(res, 0);
    expect(ciphertext, isNotEmpty);

    // Setup the Dart decryption inputs
    final key = AESKey(_key);
    final algorithm = AESEncryptionAlgo(key);
    final iv2 = InitialisationVector(IV.allZerosOfLength(16).bytes);

    // Do the Dart decryption and data decoding
    final cipherBytes = base64Decode(ciphertext);
    final plainBytes = algorithm.decrypt(cipherBytes, iv: iv2);
    final plainText2 = utf8.decode(plainBytes);

    // Verify the decrypted plaintext is the same as the original plaintext
    expect(plainText2, _plaintext);
  });
}
