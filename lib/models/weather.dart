class DailyForecast {
  final String dayName;
  final double minTemp;
  final double maxTemp;
  final int weatherCode;
  final String condition;

  const DailyForecast({
    required this.dayName,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherCode,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'minTemp': minTemp,
    'maxTemp': maxTemp,
    'weatherCode': weatherCode,
    'condition': condition,
  };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
    dayName: json['dayName'] as String,
    minTemp: (json['minTemp'] as num).toDouble(),
    maxTemp: (json['maxTemp'] as num).toDouble(),
    weatherCode: (json['weatherCode'] as num).toInt(),
    condition: json['condition'] as String,
  );
}

class WeatherData {
  final String destinationName;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final String condition;
  final DateTime lastUpdated;
  final List<DailyForecast> dailyForecast;

  const WeatherData({
    required this.destinationName,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.condition,
    required this.lastUpdated,
    required this.dailyForecast,
  });

  static String codeToCondition(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 71 && code <= 77) return 'Snowfall';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Partly cloudy';
  }

  Map<String, dynamic> toJson() => {
    'destinationName': destinationName,
    'temperature': temperature,
    'windSpeed': windSpeed,
    'humidity': humidity,
    'weatherCode': weatherCode,
    'condition': condition,
    'lastUpdated': lastUpdated.toIso8601String(),
    'dailyForecast': dailyForecast.map((f) => f.toJson()).toList(),
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    destinationName: json['destinationName'] as String,
    temperature: (json['temperature'] as num).toDouble(),
    windSpeed: (json['windSpeed'] as num).toDouble(),
    humidity: (json['humidity'] as num).toInt(),
    weatherCode: (json['weatherCode'] as num).toInt(),
    condition: json['condition'] as String,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    dailyForecast: (json['dailyForecast'] as List? ?? [])
        .map((f) => DailyForecast.fromJson(Map<String, dynamic>.from(f)))
        .toList(),
  );
}
