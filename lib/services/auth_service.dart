import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import 'api_client.dart';

class AuthService {
  static Future<AuthUser> registerAccount({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required UploadFileData identityImage,
    UploadFileData? identityImageBack,
    String? plateNumber,
    String? vehicleType,
    String? vehicleMake,
    String? vehicleColor,
    String? vehicleModel,
    UploadFileData? vehiclePhoto,
    UploadFileData? vehiclePhotoBack,
  }) async {
    final fields = <String, String>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
    final files = <String, UploadFileData>{'id_image': identityImage};

    if (identityImageBack != null) {
      files['id_image_back'] = identityImageBack;
    }

    if (role == 'driver') {
      fields.addAll({
        'plate_number': plateNumber ?? '',
        'vehicle_type': vehicleType ?? '',
        'vehicle_make': vehicleMake ?? '',
        'vehicle_color': vehicleColor ?? '',
        'vehicle_model': vehicleModel ?? '',
        'vehicle_photo_consent': '1',
      });

      if (vehiclePhoto != null) {
        files['vehicle_photo'] = vehiclePhoto;
      }
      if (vehiclePhotoBack != null) {
        files['vehicle_photo_back'] = vehiclePhotoBack;
      }
    }

    final response = await ApiClient.postMultipart(
      'register',
      fields: fields,
      files: files,
    );

    ApiClient.requireStatus(response, const {201});
    return _saveSessionFromResponse(response);
  }

  static Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.postJson(
      'login',
      body: {'email': email, 'password': password},
    );

    ApiClient.requireStatus(response, const {200});
    return _saveSessionFromResponse(response);
  }

  static Future<void> logout() async {
    final token = await authToken();

    if (token != null && token.isNotEmpty) {
      try {
        await ApiClient.post('logout', headers: bearerHeaders(token));
      } catch (_) {
        // A local logout must still work while the server is unavailable.
      }
    }

    await clearSession();
  }

  static Future<void> deleteAccount({String? password}) async {
    final token = await requireToken();

    final body = (password != null && password.isNotEmpty)
        ? {'password': password}
        : null;

    try {
      final response = await ApiClient.deleteJson(
        'account',
        headers: bearerHeaders(token),
        body: body,
      );

      if (response.statusCode == 404 || response.statusCode == 405) {
        final fallback = await ApiClient.postJson(
          'account/delete',
          headers: bearerHeaders(token),
          body: body,
        );
        ApiClient.requireStatus(fallback, const {200, 204});
      } else {
        ApiClient.requireStatus(response, const {200, 204});
      }
    } finally {
      await clearSession();
    }
  }

  static Future<AuthUser?> fetchMe() async {
    final token = await authToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await ApiClient.get('me', headers: bearerHeaders(token));

    if (response.statusCode == 401) {
      await clearSession();
      return null;
    }

    ApiClient.requireStatus(response, const {200});
    final body = ApiClient.decodeObject(response);
    final userData = body['user'];

    if (userData is! Map) {
      throw const ApiException('The account response is incomplete.');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userData));
    await _saveUserOnly(user);
    return user;
  }

  static Future<String> resendVerificationEmail() async {
    final token = await requireToken();
    final response = await ApiClient.post(
      'email/verification-notification',
      headers: bearerHeaders(token),
    );
    ApiClient.requireStatus(response, const {200});
    return ApiClient.decodeObject(response)['message']?.toString() ??
        'Verification email sent.';
  }

  static Future<String?> authToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String> requireToken() async {
    final token = await authToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Your session has expired. Please log in again.',
      );
    }
    return token;
  }

  static Map<String, String> bearerHeaders(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  static Future<bool> isLoggedIn() async {
    final token = await authToken();
    return token != null && token.isNotEmpty;
  }

  static Future<AuthUser?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      return null;
    }

    final id = prefs.getInt('user_id');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final role = prefs.getString('user_role');

    if (id == null || name == null || email == null || role == null) {
      return null;
    }

    return AuthUser(
      id: id,
      name: name,
      email: email,
      role: role,
      verificationStatus: prefs.getString('verification_status') ?? 'pending',
      emailVerified: prefs.getBool('email_verified') ?? false,
      hasApprovedVehicle: prefs.getBool('has_approved_vehicle') ?? false,
      canReserve: prefs.getBool('can_reserve') ?? false,
      canManageParkingSpaces:
          prefs.getBool('can_manage_parking_spaces') ?? false,
      remainingVehicleSlots: prefs.getInt('remaining_vehicle_slots') ?? 0,
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('verification_status');
    await prefs.remove('email_verified');
    await prefs.remove('has_approved_vehicle');
    await prefs.remove('can_reserve');
    await prefs.remove('can_manage_parking_spaces');
    await prefs.remove('remaining_vehicle_slots');
  }

  static Future<AuthUser> _saveSessionFromResponse(
    http.Response response,
  ) async {
    final body = ApiClient.decodeObject(response);
    final token = body['token'];
    final userData = body['user'];

    if (token is! String || token.isEmpty || userData is! Map) {
      throw const ApiException('The authentication response is incomplete.');
    }

    final user = AuthUser.fromJson(Map<String, dynamic>.from(userData));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await _saveUserOnly(user);
    return user;
  }

  static Future<void> _saveUserOnly(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
    await prefs.setString('verification_status', user.verificationStatus);
    await prefs.setBool('email_verified', user.emailVerified);
    await prefs.setBool('has_approved_vehicle', user.hasApprovedVehicle);
    await prefs.setBool('can_reserve', user.canReserve);
    await prefs.setBool(
      'can_manage_parking_spaces',
      user.canManageParkingSpaces,
    );
    await prefs.setInt('remaining_vehicle_slots', user.remainingVehicleSlots);
  }
}
