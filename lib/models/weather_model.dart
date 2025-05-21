class WeatherModel {
  final DateTime horario;
  final double? tempArEcmwf;
  final double? tempArNoaa;
  final double? tempArSg;

  WeatherModel({
    required this.horario,
    this.tempArEcmwf,
    this.tempArNoaa,
    this.tempArSg,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      horario: DateTime.parse(json['horario']),
      tempArEcmwf: (json['temp_ar_ecmwf'] as num?)?.toDouble(),
      tempArNoaa: (json['temp_ar_noaa'] as num?)?.toDouble(),
      tempArSg: (json['temp_ar_sg'] as num?)?.toDouble(),
    );
  }
}
