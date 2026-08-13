enum Environment { dev, prod }

class AppConfig {
  static Environment environment = Environment.dev;

  // IMPORTANT: For physical Android testing, replace this IP with your computer's local Wi-Fi IP
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

  static const int connectTimeout = 10000; // 10s
  static const int receiveTimeout = 10000; // 10s
  static const int pageSize = 20;
}