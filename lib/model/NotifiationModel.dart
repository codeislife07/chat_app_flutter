// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {

  NotificationModel({
    required this.status,
    required this.msg,
    required this.uid,
    required this.time
  });

  int status;
  String msg;
  String uid;
  String time;


  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    status: json["status"],
    msg: json["msg"],
    uid: json["uid"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "msg": msg,
    "uid": uid,
    "time": time,
  };
}
