import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthService(client);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final BusinessModel? activeBusiness;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.activeBusiness,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    BusinessModel? activeBusiness,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      activeBusiness: activeBusiness ?? this.activeBusiness,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    final loggedIn = await _authService.isLoggedIn();
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: loggedIn,
    );
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _authService.login(phone, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: res['user'],
        activeBusiness: res['business'],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp, {String? name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _authService.verifyOtp(phone, otp, name: name);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: res['user'],
        activeBusiness: res['business'],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    String? businessName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _authService.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        businessName: businessName,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: res['user'],
        activeBusiness: res['business'],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> requestOtp(String phone, {String purpose = 'LOGIN'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.requestOtp(phone, purpose: purpose);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
