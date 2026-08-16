enum Environment { dev, prod }

class AppConfig {
  // Flip this manually when you're ready to point the app at your deployed backend.
  static Environment environment = Environment.dev;

  static bool get isProduction => environment == Environment.prod;

  // Because you are using 'adb reverse tcp:5000 tcp:5000', the physical phone 
  // can directly access your PC's local server using localhost!
  static const String _devBaseUrl = 'http://localhost:5000/api';
  
  // This will be used later if you ever upload your backend to the internet
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