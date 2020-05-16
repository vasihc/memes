class Settings {
  final String key;
  final String value;

  Settings({this.key, this.value});

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

    
  factory Settings.fromMap(Map<String, dynamic> json) {
    return Settings(
      key: json['key'],
      value: json['value'],
    );
  }
}
