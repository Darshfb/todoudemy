class TodoModel {
  final int id;
  final String title;
  final String date;
  final String time;
  final String description;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      date: json['date'],
    );
  }
}
