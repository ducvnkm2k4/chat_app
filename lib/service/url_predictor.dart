import 'package:flutter/services.dart';

class NativeUrlDetector {
  static const platform = MethodChannel('url_detector');

  static Future<double?> predictUrl(String url) async {
    try {
      final score = await platform.invokeMethod('predictURL', {
        'url': url,
      });
      return score as double?;
    } on PlatformException catch (e) {
      print("Failed to detect URL: '${e.message}'.");
      return null;
    }
  }
}
