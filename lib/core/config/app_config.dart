enum Environment { dev, prod }

class AppConfig {
  // Flip this manually when you're ready to point the app at your deployed backend.
  static Environment environment = Environment.dev;

  static bool get isProduction => environment == Environment.prod;

  // IMPORTANT: For physical device testing (Android or iOS), replace this with your
  // computer's local Wi-Fi IP — run `ipconfig` (Windows) or `ipconfig getifaddr en0`
  // (Mac) in a terminal. Your phone and computer must be on the same Wi-Fi network.
  // Do NOT use 'localhost' or '127.0.0.1' here — on a physical device that points
  // at the phone itself, not your computer.
  static const String _devBaseUrl = 'http://192.168.1.100:5000/api';
  static const String _prodBaseUrl = 'https://api.yourdomain.com/api';

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return _devBaseUrl;
      case Environment.prod:
        return _prodBaseUrl;
    }
  }

  // Dio 5.x expects Duration for these, not a raw int of milliseconds.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const int pageSize = 20;
}