import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final String? token;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _dio = Dio();
  //static const _baseUrl = 'http://localhost:8080/api/v1';
  static const _baseUrl = 'http://10.0.2.2:8080/api/v1';


  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final token = response.data['access_token'];
      await _saveToken(token);
      
      state = state.copyWith(
        isLoading: false,
        token: token,
      );
    } on DioException catch (e) {
      String backendMessage = 'Erro ao fazer login.';

      if (e.response != null && e.response?.data != null) {
        backendMessage += '\n' + (e.response?.data['error'] ?? e.response.toString());
      } else {
        backendMessage += '\n' + e.message!;
      }

      //print('Erro Dio: $backendMessage');

      state = state.copyWith(
        isLoading: false,
        error: backendMessage,
      );
    } catch (e) {
      print('Erro inesperado: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      
      final user = UserModel.fromJson(response.data['user']);
      await login(email, password);
      
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao criar conta. Tente novamente.',
      );
    }
  }

  Future<void> logout() async {
    await _removeToken();
    state = AuthState();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
} 