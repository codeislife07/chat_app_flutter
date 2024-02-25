import 'package:encrypt/encrypt.dart';

class ChatModel {
  String? msg;
  String? sender;
  String? reciver;
  var time;
  int? number;

  ChatModel(this.msg, this.sender, this.reciver,this.time,this.number);
}