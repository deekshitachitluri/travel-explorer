import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/weather.dart';

class WeatherServiceException implements Exception {
  final String message;
  WeatherServiceException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  final http.Client _client;

  // In-memory cache: key = "$lat,$lon", value = (WeatherData, timestamp)
  final Map<String, (WeatherData, DateTime)> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 30);

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> fetchWeather({
    required String destinationName,
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final (cachedData, cachedTime) = _cache[cacheKey]!;
      if (DateTime.now().difference(cachedTime) < _cacheDuration) {
        return cachedData;
      }
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto',
    );

    try {
      final response = await _client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw WeatherServiceException(
                'Weather request timed out. Please check your connection.',
              );
            },
          );

      if (response.statusCode != 200) {
        throw WeatherServiceException(
          'Open-Meteo service responded with error (${response.statusCode})',
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final current = data['current'] as Map<String, dynamic>?;
      if (current == null) {
        throw WeatherServiceException(
          'Incomplete weather data received from Open-Meteo.',
        );
      }

      final temperature = (current['temperature_2m'] as num).toDouble();
      final humidity = (current['relative_humidity_2m'] as num).toInt();
      final windSpeed = (current['wind_speed_10m'] as num).toDouble();
      final weatherCode = (current['weather_code'] as num).toInt();
      final condition = WeatherData.codeToCondition(weatherCode);

      final daily = data['daily'] as Map<String, dynamic>?;
      final List<DailyForecast> forecasts = [];

      if (daily != null) {
        final times = daily['time'] as List<dynamic>? ?? [];
        final maxTemps = daily['temperature_2m_max'] as List<dynamic>? ?? [];
        final minTemps = daily['temperature_2m_min'] as List<dynamic>? ?? [];
        final codes = daily['weather_code'] as List<dynamic>? ?? [];

        final count = times.length > 5 ? 5 : times.length;
        for (int i = 0; i < count; i++) {
          final dateStr = times[i] as String;
          final date =
              DateTime.tryParse(dateStr) ??
              DateTime.now().add(Duration(days: i));
          final dayName = i == 0 ? 'Today' : DateFormat('EEE').format(date);
          final code = (codes[i] as num).toInt();
          forecasts.add(
            DailyForecast(
              dayName: dayName,
              minTemp: (minTemps[i] as num).toDouble(),
              maxTemp: (maxTemps[i] as num).toDouble(),
              weatherCode: code,
              condition: WeatherData.codeToCondition(code),
            ),
          );
        }
      }

      final weatherResult = WeatherData(
        destinationName: destinationName,
        temperature: temperature,
        windSpeed: windSpeed,
        humidity: humidity,
        weatherCode: weatherCode,
        condition: condition,
        lastUpdated: DateTime.now(),
        dailyForecast: forecasts,
      );

      _cache[cacheKey] = (weatherResult, DateTime.now());
      return weatherResult;
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException(
        'Unable to load live weather. Please verify your internet connection.',
      );
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
