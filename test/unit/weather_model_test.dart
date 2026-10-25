import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/models/weather.dart';

void main() {
  group('Weather Model & Code Conversion Tests', () {
    test('Converts WMO weather codes to user-friendly conditions', () {
      expect(WeatherData.codeToCondition(0), equals('Clear sky'));
      expect(WeatherData.codeToCondition(1), equals('Mainly clear'));
      expect(WeatherData.codeToCondition(2), equals('Partly cloudy'));
      expect(WeatherData.codeToCondition(3), equals('Overcast'));
      expect(WeatherData.codeToCondition(45), equals('Foggy'));
      expect(WeatherData.codeToCondition(61), equals('Rain'));
      expect(WeatherData.codeToCondition(71), equals('Snowfall'));
      expect(WeatherData.codeToCondition(95), equals('Thunderstorm'));
    });

    test('WeatherData serializes and deserializes accurately', () {
      final weather = WeatherData(
        destinationName: 'Manali',
        temperature: 12.5,
        windSpeed: 8.2,
        humidity: 65,
        weatherCode: 2,
        condition: 'Partly cloudy',
        lastUpdated: DateTime(2026, 10, 24, 10, 30),
        dailyForecast: [
          const DailyForecast(
            dayName: 'Today',
            minTemp: 6.0,
            maxTemp: 15.0,
            weatherCode: 0,
            condition: 'Clear sky',
          ),
          const DailyForecast(
            dayName: 'Sun',
            minTemp: 7.0,
            maxTemp: 16.0,
            weatherCode: 1,
            condition: 'Mainly clear',
          ),
        ],
      );

      final json = weather.toJson();
      final parsed = WeatherData.fromJson(json);

      expect(parsed.destinationName, equals('Manali'));
      expect(parsed.temperature, equals(12.5));
      expect(parsed.dailyForecast.length, equals(2));
      expect(parsed.dailyForecast.first.dayName, equals('Today'));
      expect(parsed.dailyForecast.first.maxTemp, equals(15.0));
    });
  });
}
