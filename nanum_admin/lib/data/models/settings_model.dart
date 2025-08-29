// nanum_admin/lib/data/models/settings_model.dart

class Setting {
  final String key;
  final String? value;
  final String? comment;

  Setting({required this.key, this.value, this.comment});

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      key: json['key'],
      value: json['value'],
      comment: json['comment'],
    );
  }
}