import 'package:flutter/widgets.dart';

Widget fileImage(String path, {double? height, double? width, BoxFit? fit}) {
  return Image.network(path, height: height, width: width, fit: fit);
}
