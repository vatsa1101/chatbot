class Chat {
  final String id;
  final bool sentByUser;
  final DateTime time;
  final String text;

  const Chat({
    required this.id,
    required this.sentByUser,
    required this.text,
    required this.time,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json["id"],
      sentByUser: json["sentByUser"],
      text: json["text"],
      time: DateTime.parse(json["time"]),
    );
  }
}
