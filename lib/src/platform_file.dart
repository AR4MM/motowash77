// Conditional export: use real dart:io File when available, otherwise use stub.
export 'file_stub.dart' if (dart.library.io) 'dart:io';
