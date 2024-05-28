class CancellApplication {
  final int id;
  final String zayavka;
  final String kommentarii;
  final String old_status;
  final String new_status;
  final String user;


  CancellApplication({
    required this.id,
    required this.zayavka,
    required this.kommentarii,
    required this.old_status,
    required this.new_status,
    required this.user,
  });

  factory CancellApplication.fromJson(Map<String, dynamic> json) {
    return CancellApplication(
      id: json['id'],
      zayavka: json['zayavka'].toString(),
      kommentarii: json['kommentarii'].toString(),
      old_status: json['old_status'].toString(),
      new_status: json['new_status'].toString(),
      user: json['user'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zayavka': zayavka,
      'kommentarii': kommentarii,
      'old_status': old_status,
      'new_status': new_status,
      'user': user,
    };
  }
}
