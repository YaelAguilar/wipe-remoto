class SensitiveData {
  String id;
  String title;
  String type;
  String content;
  String lastAccessed;
  bool isVisible;
  final String icon;

  SensitiveData({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    required this.lastAccessed,
    this.isVisible = false,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'content': content,
        'lastAccessed': lastAccessed,
        'isVisible': isVisible,
        'icon': icon,
      };

  factory SensitiveData.fromJson(Map<String, dynamic> json) => SensitiveData(
        id: json['id'],
        title: json['title'],
        type: json['type'],
        content: json['content'],
        lastAccessed: json['lastAccessed'],
        isVisible: json['isVisible'] ?? false,
        icon: json['icon'],
      );
}