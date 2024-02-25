// To parse this JSON data, do
//
//     final requestsModel = requestsModelFromJson(jsonString);

import 'dart:convert';

RequestsModel requestsModelFromJson(String str) => RequestsModel.fromJson(json.decode(str));

String requestsModelToJson(RequestsModel data) => json.encode(data.toJson());

class RequestsModel {
  RequestsModel({
    required this.msg,
    required this.uid,
    required this.time,
  });

  String msg;
  String uid;
  String time;

  factory RequestsModel.fromJson(Map<String, dynamic> json) => RequestsModel(
    msg: json["msg"],
    uid: json["uid"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "uid": uid,
    "time": time,
  };
}
