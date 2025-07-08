class SavedCalculation {
  final String name;
  final String data;
  final DateTime date;

  SavedCalculation({
    required this.name,
    required this.data,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'data': data,
        'date': date.toIso8601String(),
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) {
    return SavedCalculation(
      name: json['name'],
      data: json['data'],
      date: DateTime.parse(json['date']),
    );
  }
}
