import 'dart:ffi' as c;

import 'dart:io' show Platform, Directory;
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
  c.Pointer<c.Char>,
  c.UnsignedLong,
  c.Int32,
  c.Pointer<c.UnsignedChar>,
  c.UnsignedLong,
  c.Pointer<c.UnsignedChar>,
  c.UnsignedLong,
  c.Pointer<c.UnsignedLong>,
);

typedef AtchopsAesctrEncrypt = int Function(
  c.Pointer<c.Char>,
  int,
  int,
  c.Pointer<c.Uint8>,
  int,
  c.Pointer<c.Uint8>,
  int,
  c.Pointer<c.Uint32>,
);

main() {
  test("sample", () {});
}
