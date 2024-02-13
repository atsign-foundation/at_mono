import 'dart:ffi' as c;

import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

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

const _key = "A17BC32C7E9440BBACA2ECF12FD03481F79CF52598BF47BF27BD6FFE34937BFA";
const _iv = "C777A7F5A835F5919DAA4DF23DB97D68";
const _plaintext = "Hello, world!";
main() {
  test("C encrypt - Dart decrypt", () {
    //
    final encryptPointer =
        dylib.lookup<c.NativeFunction<atchops_aesctr_encrypt>>(
            'atchops_aesctr_encrypt');
    final encrypt = encryptPointer.asFunction<AtchopsAesctrEncrypt>();

    final keybase64 = _key.toNativeUtf8();
    final iv = _iv.toNativeUtf8();
    final plaintext = _plaintext.toNativeUtf8();

    final bufSize = _plaintext.length + 1 + (16 - (16 % _plaintext.length));
    final buffer = malloc<Utf8>(bufSize);

    final outlen = malloc<c.UnsignedLong>();

    encrypt(keybase64, _key.length, 256, iv, plaintext, _plaintext.length,
        buffer, bufSize, outlen);

    final ciphertext = buffer.toDartString();
    // TODO: decrypt ciphertext in dart and compare
  });
}
