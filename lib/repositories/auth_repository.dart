import '../core/constants/api_endpoints.dart';
import '../core/network/http_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_profile.dart';

class AuthRepository {
  final HttpClient _httpClient;
  final SecureStorageService _secureStorage;

  AuthRepository({
    HttpClient? httpClient,
    SecureStorageService? secureStorage,
  })  : _httpClient = httpClient ?? HttpClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    final profile = UserProfile.fromJson(userJson);
    await _secureStorage.saveAuthToken(token);
    await _secureStorage.saveUserId(profile.id);

    return profile;
  }

  Future<UserProfile> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String bio = '',
  }) async {
    final response = await _httpClient.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'username': username,
        'email': email,
        'password': password,
        'bio': bio,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    final profile = UserProfile.fromJson(userJson);
    await _secureStorage.saveAuthToken(token);
    await _secureStorage.saveUserId(profile.id);

    return profile;
  }

  Future<UserProfile?> getProfile() async {
    final token = await _secureStorage.getAuthToken();
    if (token == null) return null;

    final response = await _httpClient.get(ApiEndpoints.profile);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _httpClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}