import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:chat_ui_kit/chat_ui_kit.dart' hide ChatMessageImage;
import 'package:chatapp/constant/AppColors.dart';
import 'package:chatapp/model/chat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:chat_ui_kit/chat_ui_kit.dart';
import 'package:chatapp/Firebase/firebaseInstance.dart';
import 'package:chatapp/Firebase/notification/NotificationService.dart';
import 'package:chatapp/Screen/chat/chat_viewmodel.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/chat_message.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/Screen/chat/chat_screen.dart';
import 'package:chatapp/util/Shared_Preference.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:chatapp/function/MyFunction.dart';
import '../Screen/chat/chat_screen.dart';
import '../constant/AppString.dart';
import '../function/MyFunction.dart';
import '../model/ChatModel.dart';
import '../model/UserModel.dart';
import '../util/date_formatter.dart';

class ChatProvider extends ChangeNotifier{
  UserModel? sender;
  UserModel? reciver;
  List<ChatModel> chats=[];
  int chatlength=0;
  // var msg=TextEditingController();

  DatabaseReference? Database;
  int max=0;
  var scrolController=ScrollController();
  final ChatViewModel _model = ChatViewModel();

  final TextEditingController textController = TextEditingController();
  /// The data controller
  final MessagesListController controller = MessagesListController();

  /// Whether at least 1 message is selected
  int selectedItemsCount = 0;

  // var chat;
  List<ChatMessage> chatmassages=[];

  ChatUser? senderMember;

  ChatUser? reciverMember;

  /// Whether it's a group chat (more than 2 users)
  bool get _isGroupChat =>false;
      // widget.args.chat.members.length > 2;
  //
  ChatWithMembers? chat;

 // ChatUser get _currentUser => _model.localUser;
  ChatProvider(String recivers){
    //reciver=recivers;
    Shared_Preferences.prefSetString("reciver", recivers);
    Shared_Preferences.prefSetInt(recivers, 0);
    notifyListeners();
    assignData(recivers);
  }

  void assignData(uuid) async{
    AppString().chatscreenapp=true;
    // print("chatscreen");

    // print(MyApp.appnavKey.currentState);
    fbdatabase().database.child("Users").child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) {
      sender=fbdatabase().getUserfromJson(event.snapshot.value as Map);
       senderMember=ChatUser(
          id: sender!.uid!,
          username: sender!.name!,
          fullname: "",
          avatarURL: sender!.image!);
      notifyListeners();
      fbdatabase().database.child("Users").child(uuid).onValue.listen((event) {
        reciver=fbdatabase().getUserfromJson(event.snapshot.value as Map);
        reciverMember=ChatUser(
            id: reciver!.uid!,
            username: reciver!.name!,
            fullname: "",
            avatarURL: reciver!.image!);
        chat=ChatWithMembers(members: [senderMember!,reciverMember!]);
        notifyListeners();
        fetchlist();
        controller.selectionEventStream.listen((event) {
          //setState(() {
          selectedItemsCount = event.currentSelectionCount;
          notifyListeners();
          //});
        });
        notifyListeners();
      });
      notifyListeners();
    });
    }
    fetchlist(){
    max+=50;
    notifyListeners();
      var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
      fbdatabase().database.child("chatroom").child(sendroom).limitToLast(max).onValue.listen((event) {
        var data=event.snapshot.value;
        chats.clear();
        controller.removeItems(chatmassages);
        chatmassages.clear();
        if(data!=null){
          var datas=data as Map;
          datas.forEach((key, value) {
            // print(data[key]['msg']);
            // print(DateTime.parse(data[key]['time']).millisecondsSinceEpoch);
            //data[key]['msg']
            chatmassages.add(ChatMessage(attachment: data[key]['attachment'],type:data[key]['msg']=="photo"?ChatMessageType.image:data[key]['msg']=="audio"?ChatMessageType.audio:data[key]['msg']=="video"?ChatMessageType.video:ChatMessageType.text ,id:data[key]['sender'],chatId: data[key]['time'],text:data[key]['msg'].runtimeType!=(List<Object?>)?"":utf8.decode((data[key]['msg'].cast<int>())),creationTimestamp: DateTime.parse(data[key]['time']).millisecondsSinceEpoch,author:data[key]['sender']==sender!.uid?senderMember:reciverMember,));
            chats.add(ChatModel(data[key]['msg'].runtimeType!=(List<Object?>)?data[key]['msg']:utf8.decode((data[key]['msg'].cast<int>())), data[key]['sender'], data[key]['reciver'],DateTime.parse(data[key]['time']),0));
          });
        }
        // chats.sort((a,b)=>a.time!.compareTo(b.time!));
        chatmassages.sort((a,b)=>b.creationTimestamp!.compareTo(a.creationTimestamp!));
          //  scrolController.jumpTo(scrolController.position.maxScrollExtent);
        controller.addAll(chatmassages);
        notifyListeners();
      });
    notifyListeners();
    }
  void sendMessage(String text)async {
    //final encrypted = AppString().encrypter.encrypt(msg.text, iv: AppString().ivEncrypt);
    var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
    //var d=utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
    var reciverroom="${reciver!.uid!}${FirebaseAuth.instance.currentUser!.uid}";
    if(text.isNotEmpty){
      //create uuid
      var uuid=chatlength;
      var data={
        'sender':FirebaseAuth.instance.currentUser!.uid,
        'msg':utf8.encode(text),
        'reciver':reciver!.uid,
        "time":DateTime.now().toString(),
         };

      notifyListeners();
      await fbdatabase().database.child("chatroom").child(sendroom).child((DateTime.now()).microsecondsSinceEpoch.toString()).set(data);

      await fbdatabase().database.child("chatroom").child(reciverroom).child(DateTime.now().microsecondsSinceEpoch.toString()).set(data);

      data.addAll({"number":0});

      // fbdatabase().notification.child(sender!.uid!).child(reciver!.uid!).onValue.listen((event) async {
      //   print("notification");
      //   var data=event.snapshot.value ?? null;
      //   if(data!=null){
      //     var datas=data as Map;
      //     datas.forEach((key, value) {
      //
      //     });
      //
      //   }else{
      //      var datas=await fbdatabase().fake.get();
      //       print("Fake or not $datas");
      //   }
      //
      // });

      await fbdatabase().database.child("recent").child(sender!.uid!).child(reciver!.uid!).set(data);
      await fbdatabase().database.child("recent").child(reciver!.uid!).child(sender!.uid!).set(data);
      NotificationService().sendNotifiation(to: reciver!.fcm!,
          otherParamters:{
            "title":"${sender!.name}",
            "body":"${text}",
            'user':"${sender!.uid}",
            "image":sender!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":sender!.image!,
            "action":"chat"
          }
      );
      // msg.text="";
    }else{
      //error code
      DangerAlertBox(context: MyApp.appnavKey.currentContext,
          title: "Message is Empty".tr,
          messageText: "",
          buttonText: "Close".tr
      );

    }
  }
  /// Called when the user pressed the top right corner icon
  void onChatDetailsPressed() {
    print("Chat details pressed");
  }

  void onMessageSend(String text) {
    sendMessage(text);
    notifyListeners();

  }

  void onTypingEvent(TypingEvent event) {
    print("typing event received: $event");
  }

  /// Copy the selected comment's comment to the clipboard.
  /// Reset selection once copied.
  void copyContent() {
    String text = "";
    controller.selectedItems.forEach((element) {
      text += element.text ?? "";
      text += '\n';
    });
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      print("text selected");
      controller.unSelectAll();
    });
  }

  void deleteSelectedMessages() {
    var get=controller.selectedItems;
    var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
    //var d=utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
    var reciverroom="${reciver!.uid!}${FirebaseAuth.instance.currentUser!.uid}";
    print("Remover $get");
    //update app bar
    showDialog(context: MyApp.appnavKey.currentContext!, builder: (BuildContext context) {
      return AlertDialog(
        content: new Container(
          width: 260.0,
          height: 230.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius:
            new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // dialog top
              new Expanded(
                child: new Row(
                  children: <Widget>[
                    new Container(
                      // padding: new EdgeInsets.all(10.0),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                      ),
                      child: new Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // dialog centre
              new Expanded(
                child: new Container(
                    child: new TextField(
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: new EdgeInsets.only(
                            left: 10.0,
                            top: 10.0,
                            bottom: 10.0,
                            right: 10.0),
                        hintText: ' add review',
                        hintStyle: new TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.0,
                          fontFamily: 'helvetica_neue_light',
                        ),
                      ),
                    )),
                flex: 2,
              ),

              // dialog bottom
              new Expanded(
                child: new Container(
                  padding: new EdgeInsets.all(16.0),
                  decoration: new BoxDecoration(
                    color: const Color(0xFF33b17c),
                  ),
                  child: new Text(
                    'Rate product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontFamily: 'helvetica_neue_light',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },

    );
    controller.removeSelectedItems();
    notifyListeners();
  }

  Widget buildChatTitle() {
    if (_isGroupChat) {
      return Text(chat!.name);
    } else {
      final _user = chat!.membersWithoutSelf.first;
      return Row(children: [
        ClipOval(
            child: Image.network(_user.avatar=="" || _user.avatar==null?"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQiaLO5Z4Ga_OJMvDSNnn2b_UT6iMUvWU2Btg&usqp=CAU":_user.avatar,
                width: 32, height: 32, fit: BoxFit.cover)),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(_user.username ?? "",
                    overflow: TextOverflow.ellipsis)))
      ]);
    }
  }



  Widget buildDate(BuildContext context, DateTime date) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
                child: Text(
                    DateFormatter.getVerboseDateTimeRepresentation(
                        context, date),
                    style:
                    TextStyle(color: Theme.of(context).disabledColor)))));
  }

  Widget buildEventMessage(context, animation, index, item, messagePosition) {
    final _chatMessage = item as ChatMessage;
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
                child: Text(
                  _chatMessage.messageText(senderMember!.id),
                  style: TextStyle(color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ))));
  }



  /// Override [MessagePosition] to return [MessagePosition.isolated] when
  /// our [ChatMessage] is an event
  MessagePosition messagePosition(
      MessageBase? previousItem,
      MessageBase currentItem,
      MessageBase? nextItem,
      bool Function(MessageBase currentItem) shouldBuildDate) {
    ChatMessage? _previousItem = previousItem as ChatMessage?;
    final ChatMessage _currentItem = currentItem as ChatMessage;
    ChatMessage? _nextItem = nextItem as ChatMessage?;

    if (shouldBuildDate(_currentItem)) {
      _previousItem = null;
    }

    if (_nextItem?.isTypeEvent == true) _nextItem = null;
    if (_previousItem?.isTypeEvent == true) _previousItem = null;

    if (_previousItem?.author?.id == _currentItem.author?.id &&
        _nextItem?.author?.id == _currentItem.author?.id) {
      return MessagePosition.surrounded;
    } else if (_previousItem?.author?.id == _currentItem.author?.id &&
        _nextItem?.author?.id != _currentItem.author?.id) {
      return MessagePosition.surroundedTop;
    } else if (_previousItem?.author?.id != _currentItem.author?.id &&
        _nextItem?.author?.id == _currentItem.author?.id) {
      return MessagePosition.surroundedBot;
    } else {
      return MessagePosition.isolated;
    }
  }

  void onSendPhoto() async{
    showLoader();
    var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
    //var d=utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
    var reciverroom="${reciver!.uid!}${FirebaseAuth.instance.currentUser!.uid}";
    var uuid=chatlength;
    Map<String,dynamic> data={
      'sender':FirebaseAuth.instance.currentUser!.uid,
      'msg':"photo",
      'reciver':reciver!.uid,
      "time":DateTime.now().toString(),
    };
    var status=await Permission.storage.request();
    // if(status==PermissionStatus.granted){
      var image=await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image!=null){
        final storageRef = FirebaseStorage.instance.ref();

        final storage = storageRef.child("${sender!.uid}").child(DateTime.now().millisecondsSinceEpoch.toString());
        await storage.putFile(File(image!.path  )).then((p0) async {
          print(p0);
          var image=await storage.getDownloadURL();
          data.addAll({"attachment":image});
          await fbdatabase().database.child("chatroom").child(sendroom).child((DateTime.now()).microsecondsSinceEpoch.toString()).set(data);
          await fbdatabase().database.child("chatroom").child(reciverroom).child(DateTime.now().microsecondsSinceEpoch.toString()).set(data);

          data.addAll({"number":0});
          // fbdatabase().notification.child(sender!.uid!).child(reciver!.uid!).onValue.listen((event) async {
          //   print("notification");
          //   var data=event.snapshot.value ?? null;
          //   if(data!=null){
          //     var datas=data as Map;
          //     datas.forEach((key, value) {
          //
          //     });
          //
          //   }else{
          //      var datas=await fbdatabase().fake.get();
          //       print("Fake or not $datas");
          //   }
          //
          // });
          await fbdatabase().database.child("recent").child(sender!.uid!).child(reciver!.uid!).set(data);
          await fbdatabase().database.child("recent").child(reciver!.uid!).child(sender!.uid!).set(data);
          NotificationService().sendNotifiation(to: reciver!.fcm!,
              otherParamters:{
                "title":"${sender!.name}",
                "body":"send you a photo",
                'user':"${sender!.uid}",
                "image":sender!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":sender!.image!,
                "action":"chat"
              }
          );
        });
        hideLoader();

      }else{
        hideLoader();
      }
    // }else{
    //   //error code
    //   hideLoader();
    //   DangerAlertBox(context: MyApp.appnavKey.currentContext,
    //       title: "Need storage permission".tr,
    //       messageText: "",
    //       buttonText: "Close".tr
    //   );
    //   AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
    //
    // }
  }


  void onSendAuddio()async {
      showLoader();
      var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
      //var d=utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
      var reciverroom="${reciver!.uid!}${FirebaseAuth.instance.currentUser!.uid}";
      var uuid=chatlength;
      Map<String,dynamic> data={
        'sender':FirebaseAuth.instance.currentUser!.uid,
        'msg':"audio",
        'reciver':reciver!.uid,
        "time":DateTime.now().toString(),
      };
      var status=await Permission.storage.request();
      // if(status==PermissionStatus.granted){
        //var image=await ImagePicker().pickImage(source: ImageSource.gallery);
        FilePickerResult? image = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3'],
        );

        if(image!=null){
          final storageRef = FirebaseStorage.instance.ref();

          final storage = storageRef.child("${sender!.uid}").child(DateTime.now().millisecondsSinceEpoch.toString()+".mp3");
          await storage.putFile(File(image!.files.single.path!)).then((p0) async {
            print(p0);
            var image=await storage.getDownloadURL();
            data.addAll({"attachment":image});
            await fbdatabase().database.child("chatroom").child(sendroom).child((DateTime.now()).microsecondsSinceEpoch.toString()).set(data);
            await fbdatabase().database.child("chatroom").child(reciverroom).child(DateTime.now().microsecondsSinceEpoch.toString()).set(data);

            data.addAll({"number":0});
            // fbdatabase().notification.child(sender!.uid!).child(reciver!.uid!).onValue.listen((event) async {
            //   print("notification");
            //   var data=event.snapshot.value ?? null;
            //   if(data!=null){
            //     var datas=data as Map;
            //     datas.forEach((key, value) {
            //
            //     });
            //
            //   }else{
            //      var datas=await fbdatabase().fake.get();
            //       print("Fake or not $datas");
            //   }
            //
            // });
            await fbdatabase().database.child("recent").child(sender!.uid!).child(reciver!.uid!).set(data);
            await fbdatabase().database.child("recent").child(reciver!.uid!).child(sender!.uid!).set(data);
            NotificationService().sendNotifiation(to: reciver!.fcm!,
                otherParamters:{
                  "title":"${sender!.name}",
                  "body":"send you a audio",
                  'user':"${sender!.uid}",
                  "image":sender!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":sender!.image!,
                  "action":"chat"
                }
            );
          });
          hideLoader();

        }else{
          hideLoader();
        }
      // }else{
      //   //error code
      //   hideLoader();
      //   DangerAlertBox(context: MyApp.appnavKey.currentContext,
      //       title: "Need storage permission".tr,
      //       messageText: "",
      //       buttonText: "Close".tr
      //   );
      //
      //   AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
      //
      // }

  }

  void onSendVideo()async {
    showLoader();
    var sendroom="${FirebaseAuth.instance.currentUser!.uid}${reciver!.uid}";
    //var d=utf8.encode('Lorem ipsum dolor sit amet, consetetur...');
    var reciverroom="${reciver!.uid!}${FirebaseAuth.instance.currentUser!.uid}";
    var uuid=chatlength;
    Map<String,dynamic> data={
      'sender':FirebaseAuth.instance.currentUser!.uid,
      'msg':"video",
      'reciver':reciver!.uid,
      "time":DateTime.now().toString(),
    };
    var status=await Permission.storage.request();
    // if(status==PermissionStatus.granted){
      //var image=await ImagePicker().pickImage(source: ImageSource.gallery);
      FilePickerResult? image = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4',],
      );

      if(image!=null){
        final storageRef = FirebaseStorage.instance.ref();

        final storage = storageRef.child("${sender!.uid}").child(DateTime.now().millisecondsSinceEpoch.toString()+".mp4");
        await storage.putFile(File(image!.files.single.path!)).then((p0) async {
          print(p0);
          var image=await storage.getDownloadURL();
          data.addAll({"attachment":image});
          await fbdatabase().database.child("chatroom").child(sendroom).child((DateTime.now()).microsecondsSinceEpoch.toString()).set(data);
          await fbdatabase().database.child("chatroom").child(reciverroom).child(DateTime.now().microsecondsSinceEpoch.toString()).set(data);

          data.addAll({"number":0});
          // fbdatabase().notification.child(sender!.uid!).child(reciver!.uid!).onValue.listen((event) async {
          //   print("notification");
          //   var data=event.snapshot.value ?? null;
          //   if(data!=null){
          //     var datas=data as Map;
          //     datas.forEach((key, value) {
          //
          //     });
          //
          //   }else{
          //      var datas=await fbdatabase().fake.get();
          //       print("Fake or not $datas");
          //   }
          //
          // });
          await fbdatabase().database.child("recent").child(sender!.uid!).child(reciver!.uid!).set(data);
          await fbdatabase().database.child("recent").child(reciver!.uid!).child(sender!.uid!).set(data);
          NotificationService().sendNotifiation(to: reciver!.fcm!,
              otherParamters:{
                "title":"${sender!.name}",
                "body":"send you a video",
                'user':"${sender!.uid}",
                "image":sender!.image==""?"http://www.lowellstudentassociation.org/uploads/2/1/6/8/21682486/published/blankpfp.webp":sender!.image!,
                "action":"chat"
              }
          );
        });
        hideLoader();

      }else{
        hideLoader();
      }
    // }else{
    //   //error code
    //   hideLoader();
    //   DangerAlertBox(context: MyApp.appnavKey.currentContext,
    //       title: "Need storage permission".tr,
    //       messageText: "",
    //       buttonText: "Close".tr
    //   );

      //AppSettings.openAppSettings(type: AppSettingsType.internalStorage);

    // }

  }
}

