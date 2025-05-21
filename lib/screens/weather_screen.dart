import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final token = await ref.read(authProvider.notifier).getToken();
    if (token != null) {
      await ref.read(weatherProvider.notifier).fetchWeather(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo'),
      ),
      body: weatherState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherState.error != null
              ? Center(child: Text(weatherState.error!))
              : ListView.builder(
                  itemCount: weatherState.forecast.length,
                  itemBuilder: (context, index) {
                    final weather = weatherState.forecast[index];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(dateFormat.format(weather.horario.toLocal())),
                        trailing: weather.tempArSg != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.wb_sunny, color: Colors.orange),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${weather.tempArSg!.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
