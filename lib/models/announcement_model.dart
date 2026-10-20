class Announcement {
  final int id;
  final String title;
  final String body;
  final String type;
  final String? postedBy;
  final String createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.postedBy,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      postedBy: json['posted_by'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}