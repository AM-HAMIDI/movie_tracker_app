import 'dart:async';
import 'dart:io';

class ConnectivityService {
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionStatusController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  ConnectivityService() {
    _initPingChecker();
  }

  void _initPingChecker() {
    checkInternet();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => checkInternet());
  }

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateStatus(true);
        return true;
      }
    } on SocketException catch (_) {
      _updateStatus(false);
    } on TimeoutException catch (_) {
      _updateStatus(false);
    } catch (_) {
      _updateStatus(false);
    }
    _updateStatus(false);
    return false;
  }

  void _updateStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      _connectionStatusController.add(_isOnline);
    }
  }

  void dispose() {
    _timer?.cancel();
    _connectionStatusController.close();
  }
}