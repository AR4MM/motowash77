// Conditional export: use IO implementation when available, otherwise web stub.
export 'file_image_helper_stub.dart'
    if (dart.library.io) 'file_image_helper_io.dart';
