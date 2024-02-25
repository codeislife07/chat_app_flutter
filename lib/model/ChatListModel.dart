// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);

import 'dart:convert';

ChatListModel chatListModelFromJson(String str) => ChatListModel.fromJson(json.decode(str));

String chatListModelToJson(ChatListModel data) => json.encode(data.toJson());

class ChatListModel {
  ChatListModel(
    this.author,
    this.createdAt,
    this.height,
    this.id,
    this.name,
    this.size,
    this.status,
    this.mimeType,
    this.type,
    this.text,
    this.uri,
    this.width,
  );

  Author author;
  int createdAt;
  int height;
  String id;
  String name;
  int size;
  String status;
  String mimeType;
  String type;
  List<int> text;
  String uri;
  int width;

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
     Author.fromJson(json["author"]),
     json["createdAt"],
     json["height"],
     json["id"],
     json["name"],
     json["size"],
     json["status"],
     json["mimeType"],
     json["type"],
    json["text"],
     json["uri"],
    json["width"],
  );

  Map<String, dynamic> toJson() => {
    "author": author.toJson(),
    "createdAt": createdAt,
    "height": height,
    "id": id,
    "name": name,
    "size": size,
    "status": status,
    "mimeType": mimeType,
    "type": type,
    "text": text,
    "uri": uri,
    "width": width,
  };
}

class Author {
  String firstName="";
  String id="";
  String imageUrl="";
  String lastName="";


  Author(this.firstName, this.id, this.imageUrl, this.lastName);

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    json["firstName"],
    json["id"],
     json["imageUrl"],
     json["lastName"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "id": id,
    "imageUrl": imageUrl,
    "lastName": lastName,
  };
}
