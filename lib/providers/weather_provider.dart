import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/weather_model.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});

class WeatherState {
  final bool isLoading;
  final List<WeatherModel> forecast;
  final String? error;

  WeatherState({
    this.isLoading = false,
    this.forecast = const [],
    this.error,
  });

  WeatherState copyWith({
    bool? isLoading,
    List<WeatherModel>? forecast,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      forecast: forecast ?? this.forecast,
      error: error,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final _dio = Dio();
  static const _baseUrl = 'http://10.0.2.2:8080/api/v1/climate';

  WeatherNotifier() : super(WeatherState());

  Future<void> fetchWeather(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      final forecast = data.map((json) => WeatherModel.fromJson(json)).toList();

      state = state.copyWith(isLoading: false, forecast: forecast);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar previsão do tempo.');
    }
  }
}