import 'dart:io';
import 'package:flutter/widgets.dart';

Widget fileImage(String path, {double? height, double? width, BoxFit? fit}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(path, height: height, width: width, fit: fit);
  }
  if (path.startsWith('uploads/')) {
    final fullUrl = 'http://localhost/motowash_api/$path';
    return Image.network(fullUrl, height: height, width: width, fit: fit);
  }
  return Image.file(File(path), height: height, width: width, fit: fit);
}
