class Holiday {
  final int id;
  final String name;
  final DateTime date;
  final String type;

  const Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as int,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
    );
  }
}