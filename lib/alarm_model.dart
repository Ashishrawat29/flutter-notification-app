enum RecurringType { none, daily, weekdays }

class Alarm {
  final int id;
  final DateTime dateTime;
  final String sound;
  final double volume;
  final bool enabled;
  final String label;
  final RecurringType recurring;

  Alarm({
    required this.id,
    required this.dateTime,
    this.sound = 'assets/sound1.mp3',
    this.volume = 1.0,
    this.enabled = true,
    this.label = '',
    this.recurring = RecurringType.none,
  });

  Alarm copyWith({
    int? id,
    DateTime? dateTime,
    String? sound,
    double? volume,
    bool? enabled,
    String? label,
    RecurringType? recurring,
  }) {
    return Alarm(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      sound: sound ?? this.sound,
      volume: volume ?? this.volume,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
      recurring: recurring ?? this.recurring,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'sound': sound,
    'volume': volume,
    'enabled': enabled,
    'label': label,
    'recurring': recurring.index,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      sound: json['sound'],
      volume: (json['volume'] as num).toDouble(),
      enabled: json['enabled'],
      label: json['label'],
      recurring: RecurringType.values[json['recurring']],
    );
  }
}
